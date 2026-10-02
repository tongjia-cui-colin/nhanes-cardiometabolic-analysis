# Multivariate Analysis of Cardiometabolic Health Across Demographic and Socioeconomic Groups
* Last Updated: October 2026*

## Overview
This project examines patterns of cardiometabolic health among U.S. adults using NHANES 2021–2023 data. The analysis evaluates whether BMI, waist circumference, systolic blood pressure, diastolic blood pressure, and total cholesterol jointly differ across sex, age, income, and education groups.

The focus of the project is on multivariate differences in cardiometabolic health and identifying which health indicators contribute most strongly to differences across demographic and socioeconomic groups.

## Methods
- Missing-data analysis and multiple imputation
- Multivariate Analysis of Variance (MANOVA)
- Pillai's Trace and follow-up univariate analysis
- Linear Discriminant Analysis (LDA)
- Multivariate assumption and diagnostic testing

## Key Findings
- Cardiometabolic health profiles differ significantly across sex, age, income, and education groups, with age and sex showing the largest multivariate differences.
- Follow-up analyses indicate that group differences are most strongly reflected in BMI, waist circumference, and systolic blood pressure.
- Income and education show smaller multivariate differences than age and sex despite reaching statistical significance.
- The first two discriminant functions account for approximately 95.5% of the explained separation across education groups, with the primary dimension characterized largely by systolic blood pressure, waist circumference, and BMI.
- Results suggest that education-related cardiometabolic differences reflect gradual population-level patterns rather than sharply separated health profiles.

## Limitations
This analysis uses cross-sectional NHANES data and therefore identifies associations rather than causal relationships. Educational attainment is also treated as a socioeconomic indicator and should not be interpreted as a direct measure of health literacy. The large analytic sample increases statistical power, meaning statistically significant differences, particularly those associated with income and education, may still be modest in practical magnitude.

## Tools
R; dplyr, ggplot2, mice, car, MASS
