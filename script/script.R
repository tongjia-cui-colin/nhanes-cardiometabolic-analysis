# ======================================================
# MANOVA + PCA Health Data ###########
# ======================================================

# ======================================================
# 1. Libraries
# ======================================================

library(haven)
library(dplyr)
library(mice)
library(MASS)
library(ggplot2)
library(tidyr)
library(MVN)
library(car)
library(biotools)

# ======================================================
# 2. Data Loading and Transformation
# ======================================================
demo  <- read_xpt("C:/Users/ctjia/Downloads/DEMO_L.xpt")
bmx   <- read_xpt("C:/Users/ctjia/Downloads/BMX_L.xpt")
bpxo  <- read_xpt("C:/Users/ctjia/Downloads/BPXO_L.xpt")
tchol <- read_xpt("C:/Users/ctjia/Downloads/TCHOL_L.xpt")

nhanes <- demo %>%
  left_join(bmx,   by = "SEQN") %>%
  left_join(bpxo,  by = "SEQN") %>%
  left_join(tchol, by = "SEQN") 

nhanes_analysis <- nhanes %>%
  dplyr::mutate(
    # Average BP across available readings
    sys_bp = rowMeans(dplyr::select(., BPXOSY1, BPXOSY2, BPXOSY3), na.rm = FALSE),
    dia_bp = rowMeans(dplyr::select(., BPXODI1, BPXODI2, BPXODI3), na.rm = FALSE)
  ) %>%
  dplyr::select(
    SEQN,
    RIAGENDR,     
    RIDAGEYR,     
    RIDRETH3,     
    DMDEDUC2,     
    INDFMPIR,     
    BMXBMI,       
    BMXWAIST,     
    sys_bp,
    dia_bp,
    LBXTC      
  ) %>%
  dplyr::filter(RIDAGEYR >= 20)

nhanes_analysis <- nhanes_analysis %>%
  dplyr::mutate(
    DMDEDUC2 = ifelse(DMDEDUC2 %in% c(7, 9), NA, DMDEDUC2)
  )

# Checking missingness
nhanes_analysis %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  tidyr::pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_n"
  ) %>%
  dplyr::mutate(
    total_n = nrow(nhanes_analysis),
    missing_pct = round(missing_n / total_n * 100, 2)
  ) %>%
  arrange(desc(missing_pct))

# Missingness indicators for key health outcomes
missing_check <- nhanes_analysis %>%
  dplyr::mutate(
    miss_bmi   = is.na(BMXBMI),
    miss_waist = is.na(BMXWAIST),
    miss_sysbp = is.na(sys_bp),
    miss_diabp = is.na(dia_bp),
    miss_chol  = is.na(LBXTC),
    any_missing_health = if_any(
      c(BMXBMI, BMXWAIST, sys_bp, dia_bp, LBXTC),
      is.na
    )
  )

# Missingness by sex
table(missing_check$RIAGENDR, missing_check$any_missing_health)
prop.table(table(missing_check$RIAGENDR, missing_check$any_missing_health), 1)

# Missingness by age group
missing_check <- missing_check %>%
  dplyr::mutate(
    age_group = cut(
      RIDAGEYR,
      breaks = c(19, 39, 59, Inf),
      labels = c("20-39", "40-59", "60+"),
      right = TRUE
    )
  )

table(missing_check$age_group, missing_check$any_missing_health)
prop.table(table(missing_check$age_group, missing_check$any_missing_health), 1)



# Missingness by education level
missing_check <- missing_check %>%
  dplyr::mutate(
      education = case_when(
        DMDEDUC2 %in% c(1, 2) ~ "Less than high school",
        DMDEDUC2 == 3 ~ "High school",
        DMDEDUC2 == 4 ~ "Some college or AA",
        DMDEDUC2 == 5 ~ "College graduate+",
        TRUE ~ NA_character_
      ),
      education = factor(
        education,
        levels = c(
          "Less than high school",
          "High school/GED",
          "Some college/AA",
          "College graduate+"
        )
    )
  )

table(missing_check$education, missing_check$any_missing_health)
prop.table(table(missing_check$education, missing_check$any_missing_health), 1)

# chi-square test
chisq.test(table(missing_check$RIAGENDR, missing_check$any_missing_health))
chisq.test(table(missing_check$age_group, missing_check$any_missing_health))
chisq.test(table(missing_check$education, missing_check$any_missing_health))

# Income
t.test(INDFMPIR ~ any_missing_health, data = missing_check)

# Multiple Imputation
impute_data <- nhanes_analysis %>%
  dplyr::mutate(
    RIAGENDR = factor(RIAGENDR),
    RIDRETH3 = factor(RIDRETH3),
    DMDEDUC2 = factor(DMDEDUC2)
  )

set.seed(123)

imp <- mice(
  impute_data,
  m = 20,
  method = "pmm",
  maxit = 20
)

# Complete dataset for MANOVA
analysis_imp <- complete(imp, 1)

# recode variables
analysis_imp <- analysis_imp %>%
  dplyr::mutate(
    sex = factor(RIAGENDR, levels = c(1, 2), labels = c("Male", "Female")),
    
    age_group = cut(
      RIDAGEYR,
      breaks = c(19, 39, 59, Inf),
      labels = c("20-39", "40-59", "60+"),
      right = TRUE
    ),
    
    income_group = case_when(
      INDFMPIR < 1.30 ~ "Low income",
      INDFMPIR >= 1.30 & INDFMPIR < 3.50 ~ "Middle income",
      INDFMPIR >= 3.50 ~ "Higher income"
    ),
    
    income_group = factor(
      income_group,
      levels = c("Low income", "Middle income", "Higher income")
    ),
    
    education_level = case_when(
      DMDEDUC2 == 1 ~ "Less than high school", 
      DMDEDUC2 == 2 ~ "Some high school",
      DMDEDUC2 == 3 ~ "High school",
      DMDEDUC2 == 4 ~ "Some college or associate degree", 
      DMDEDUC2 == 5 ~ "College graduate and above"
    ), 
    
    education_level = factor(
      education_level, 
      levels = c("Less than high school", "Some high school", "High school", 
                 "Some college or associate degree", "College graduate and above")
    )
    )

# ======================================================
# 3. MANOVA
# ======================================================

## Checking assumptions

# Dependent variable correlations
cor_vars <- analysis_imp %>%
  dplyr::select(BMXBMI, BMXWAIST, sys_bp, dia_bp, LBXTC)

cor(cor_vars, use = "pairwise.complete.obs")

# Multivariate normality
mvn(
  data = cor_vars,
  mvn_test = "mardia"
)

# Box's M test
boxM(
  cor_vars,
  analysis_imp$education_level
)

# Check group sizes
table(analysis_imp$sex)
table(analysis_imp$age_group)
table(analysis_imp$income_group)
table(analysis_imp$education_level)

# Model
manova_model <- manova(
  cbind(BMXBMI, BMXWAIST, sys_bp, dia_bp, LBXTC) ~
    sex + age_group + income_group + education_level,
  data = analysis_imp
)

# Tests: Wilk's Lambda and Pillai's Trace
summary(manova_model, test = "Pillai")
summary(manova_model, test = "Wilks")

# Follow-up Univariate ANOVA
summary.aov(manova_model)

# ======================================================
# 4. Discriminate Analysis
# ======================================================

## Asumption checks

# Multicollinearity check
vif(lm(BMXBMI ~ BMXWAIST + sys_bp + dia_bp + LBXTC,
       data = analysis_imp))

# Group size check
table(analysis_imp$education_level)

# Education
lda_edu <- lda(
  education_level ~ BMXBMI + BMXWAIST + sys_bp + dia_bp + LBXTC,
  data = analysis_imp
)
