## Dataset
The datasets used in this analysis are provided in .xpt format. 

## Source
This project uses data from: 
[National Health and Nutrition Examination Survey (NHANES), August 2021–August 2023](https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Cycle=2021-2023&utm_source=chatgpt.com)
National Center for Health Statistics (NCHS)
Centers for Disease Control and Prevention (CDC)

NHANES provides nationally collected demographic, examination, and laboratory data on the health and nutritional status of the U.S. population.

## Variables Used in This Project

### Outcome Variables

- **BM**I
  Body mass index.
  
- **Waist Circumference**
  Measured waist circumference.
  
- **Systolic Blood Pressure**
  Systolic blood pressure derived from NHANES oscillometric blood pressure measurements.
  
- **Diastolic Blood Pressure**
  Diastolic blood pressure derived from NHANES oscillometric blood pressure measurements.
  
- **Total Cholesterol**
  Laboratory measurement of total blood cholesterol.

### Demographic and Socioeconomic Variables

- Sex
  Participant sex.

- Age Group
  Age category constructed from participant age.

- Income Group
  Socioeconomic category based on family income-to-poverty ratio.

- Education Level
  Participant educational attainment.

## Notes

- The four datasets are merged using the NHANES participant identifier SEQN.
- Missing data are addressed during data preparation and analysis rather than by modifying the original source files.
- The original XPT files are retained in their publicly released NHANES format.
- The analysis is cross-sectional and should not be interpreted as establishing causal relationships.
