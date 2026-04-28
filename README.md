# School Discipline Risk Explorer: Virginia Public Schools

**Course:** APMA 3150 | **Group Members:** Zhang, Grace; Sejas Siles, Madison

---

## Project Title
School Discipline Risk Explorer: Virginia Public Schools (2021–2022)

## Dataset Sources
- **Civil Rights Data Collection (CRDC) 2021–2022** — U.S. Department of Education
  - https://civilrightsdata.ed.gov/data
  - Files used: School Characteristics, Enrollment, and Suspensions
  - Filtered to Virginia public schools and merged on `COMBOKEY`
This project uses publicly available data from the U.S. Department of Education Civil Rights Data Collection
(CRDC), a national survey that has monitored educational equity since 1968. The dataset includes school-level
information on enrollment, demographics, disability status, English learner populations, and discipline
outcomes.

## Research Question
To what extent do school demographics (minority enrollment, disability status) and school characteristics (size, level) predict the probability of a school having a "high" in-school suspension rate in Virginia?

## Methods Used
This project applies multiple statistical techniques, including:
Confidence interval for mean suspension rate, Correlation analysis, ANOVA comparing suspension rates across
minority-enrollment groups, Logistic regression using scaled predictors and Partial dependence curves. These
methods allow both descriptive and inferential insight into discipline patterns across Virginia schools.

## Key Findings
1. Minority Enrollment as the Primary Predictor
Strong positive association: Schools with higher minority enrollment consistently show higher suspension rates.
Supported by ANOVA: Suspension rates differ significantly across low-, medium-, and high-minority schools (p < 0.001).
Model confirmation: Minority % is the strongest predictor of being classified as a high-suspension school.
2. Disability Percentage Is Not a Significant Predictor
Raw data pattern: Schools with larger disability populations show slightly higher suspension rates.
Model-adjusted effect: After controlling for minority %, school size, and EL totals, disability % shows a small negative association with high-suspension probability that is not statistically significant (p = 0.133).
Interpretation: Disability % is not a meaningful predictor of high suspension classification once other demographic factors are accounted for.
3. Racial Disparities in Suspension Outcomes
Disparity Index findings: Among Virginia schools with calculable disparity indices, Black students are suspended at a median of 2.1 times the rate of White students, accounting for both in-school and out-of-school suspensions. In the highest-disparity schools, that ratio exceeds 3.3.
Data limitations: Only 842 of 1,900 schools had non-zero, calculable indices. The remainder reflect CRDC suppression of small counts for privacy rather than equitable outcomes.
Broader context: The typical disparity range of 1.4 to 3.3 aligns with national research consistently documenting Black students suspended at 2–4 times the rate of White students, confirming that pattern holds across Virginia schools.

## Instructions for Using the App
1. Ensure `app.R` and `va_cleaned_data.csv` are in the same directory
2. Install required packages if needed: `install.packages(c("shiny", "tidyverse", "bslib"))`
3. Open `app.R` in RStudio and click **Run App**

**Prediction tab** — Adjust the sliders and school type, then click "Update Prediction" to see the model's estimated probability of high suspension, a state benchmark comparison, and a percentile rank.

**Explore tab** — Choose an X-axis variable and color grouping to visualize relationships between demographics and suspension rate.

**Hypothesis Testing tab** — Review the t-test results and confidence interval plot comparing high vs. low minority schools.
