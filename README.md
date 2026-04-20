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

## Research Question
To what extent do school demographics (minority enrollment, disability status) and school characteristics (size, level) predict the probability of a school having a "high" in-school suspension rate in Virginia?

## Methods Used
- **Logistic Regression** — Predicts the probability of a school being "high suspension" (above state median) based on % minority enrollment, % disability, school size, and school type
- **Welch Two-Sample T-test** — Compares mean suspension rates between schools with ≥50% vs. <50% minority enrollment, with a 95% confidence interval for the difference in means

## Key Findings
- Schools with ≥50% minority enrollment had a significantly higher average suspension rate (5.05%) compared to schools with <50% minority enrollment (3.42%), p = 0.0015
- High schools and middle schools showed significantly higher risk for elevated suspension rates compared to elementary schools, even after controlling for enrollment size
- Demographic factors (minority enrollment, school level) are strong predictors of a school's statewide suspension percentile

## Instructions for Using the App
1. Ensure `app.R` and `va_cleaned_data.csv` are in the same directory
2. Install required packages if needed: `install.packages(c("shiny", "tidyverse", "bslib"))`
3. Open `app.R` in RStudio and click **Run App**

**Prediction tab** — Adjust the sliders and school type, then click "Update Prediction" to see the model's estimated probability of high suspension, a state benchmark comparison, and a percentile rank.

**Explore tab** — Choose an X-axis variable and color grouping to visualize relationships between demographics and suspension rate.

**Hypothesis Testing tab** — Review the t-test results and confidence interval plot comparing high vs. low minority schools.
