# Cardiomyopathy Risk Prediction in Childhood Cancer Survivors

his repository contains R scripts and supporting files for reproducing the statistical analyses and visualizations presented in our publication: [Predicting the 10-year risk of cardiomyopathy](https://www.sciencedirect.com/science/article/pii/S0923753425007689)

**Citation:**

> K. Petrykey, Y. Chen, A. Neupane, J.N. French, H. Wang, H. Xiang, S.B. Dixon, C. Vukadinovich, C. Im, M.J. Ehrhardt, D.A. Mulrooney, N. Sharafeldin, X. Wang, R.M. Howell, J.L. Jefferies, P.W. Burridge, K.C. Oeffinger, M.M. Gramatges, S. Bhatia, L.L. Robison, K.K. Ness, M.M. Hudson, E.J. Chow, G.T. Armstrong, Y. Yasui, Y. Sapkota. *Predicting the 10-year risk of cardiomyopathy in long-term survivors of childhood cancer*, Annals of Oncology, 2025.

## Overview

This analysis evaluates and calibrates predictive models for 10-year cardiomyopathy risk in long-term survivors of childhood cancer from:

* **St. Jude Lifetime Cohort (SJLIFE)**
* **Childhood Cancer Survivor Study (CCSS)**

A Fine-Gray subdistribution hazard model framework is used to estimate cumulative incidence functions (CIFs), accounting for death as a competing risk. Models incorporate clinical risk factors, genetic ancestry, and polygenic risk scores (PRSs).

## Repository Structure & Script Descriptions (Suggested Execution Order)

### 1. `prepare_sjlife_data.R`

Preprocesses SJLIFE phenotype, treatment, and clinical covariate data. It derives relevant variables (e.g., cardiomyopathy status, time-to-event) and formats them for model input.

### 2. `prepare_genetic_data_sjlife_ccss.R`

Cleans and merges genotype data (e.g., PRSs, ancestry PCs) with the clinical dataset for both cohorts. Filters variants, standardizes PRS scores, and annotates ancestry.

### 3. `modeling_with_CVRF_dyslip_htn_obesity_t2d_revised_v2_grade2_included_revised_baseline.R`

Performs the Fine-Gray competing risks regression models. It fits multiple models:

* Model 1: Clinical risk factors only
* Model 4: Adds hypertension
* Model 13: Final model with ancestry and 2 PRSs
  Includes model coefficients, baseline hazard estimation, and output for further analysis.

### 4. `cumulative incidence.R`

Generates CIFs for each model using the predicted linear predictors. These functions are then used to estimate individual 10-year risks.

### 5. `cumulative incidence_YS.R`

Revised version of CIF computation including Yutaka’s modifications for robustness. May adjust baseline hazards or handling of censored events.

### 6. `cumulative incidence_YS_Model4_race.R`

Calculates CIFs for Model 4 stratified by race. Allows visualization of differential cardiomyopathy risk across racial groups.

### 7. `model_calibration_revised.R`

Groups participants into risk deciles based on predicted CIFs from Model 13, then compares observed and predicted event rates. Generates calibration plots.

### 8. `AUC_overall.R`

Estimates AUC and 95% CI for each model in both SJLIFE and CCSS cohorts using logistic regression. Includes statistical tests comparing AUCs across models.

### 9. `IGHG_based_analysis.R`, `IGHG_based_analysis_revised.R`, `IGHG_based_analysis_revised_with_prs.R`

Performs sensitivity analyses in participants with IGHG risk profiles:

* Compares models with and without PRSs
* Focuses on high genetic-risk subgroups

### 10. `PRS_distribution.R`

Visualizes the distribution of PRSs across cohorts and race groups. Useful for assessing genetic variability and checking for batch effects or confounding.

## Output Files

* `Model_calibration_plots.pdf` and `Model_calibration_plots_revised_based_on_YS.pdf`: Calibration plots for various models and cohort strata.
* `AUC_overall.pdf`: AUC plot comparing model discrimination performance.
* `figure_2_all_new_13.xlsx`: Tabulated risk estimates, events, cohort identifiers used in Figure 2.

## Methods and Statistical Analysis

### Fine-Gray Competing Risk Model

* Estimates subdistribution hazard of cardiomyopathy, accounting for death as a competing risk.
* Predictors include age at diagnosis, chest radiation, cumulative anthracycline dose, hypertension, BMI, genetic ancestry, and two PRSs.
* Implemented using the `crr()` function from the `cmprsk` R package.
* Provides subdistribution hazard ratios (sHR) and cumulative incidence predictions at 10 years.

### Calibration

* Predicted risk deciles (from CIFs) compared to observed proportions.
* Observed risks estimated using non-parametric Aalen-Johansen estimator.
* Visualized via scatter plot with 45° reference line to assess agreement between predicted and observed probabilities.

### AUC/Discrimination

* ROC-based AUC estimated via logistic regression (pseudo-values for time-to-event data).
* AUC computed at 10-year time point.
* Statistical tests (e.g., DeLong test) used to compare model discrimination.
* Evaluates incremental value of PRS and genetic ancestry beyond clinical covariates.

### Sensitivity Analysis

* Stratified Fine-Gray models conducted by genetic risk categories (IGHG).
* Assessed robustness of risk estimates when restricting to specific ancestry groups or high-risk strata.

## Required R Packages

```R
install.packages(c("tidyr", "readxl", "ggplot2", "CalibrationCurves", "rms", "ggprism", "patchwork", "magrittr", "dplyr", "cmprsk"))
```

## How to Run

1. Set working directory:

   * Windows: `Z:/ResearchHome/`
   * macOS: `/Volumes/`

2. Run the scripts in order (1–10 above).

3. Visualize results from generated PDF and Excel files.

## Notes

* `Model_13` is the final model for publication.
* Cohort-specific input files must be placed in the working directory.
* Follows IRB and data-sharing guidelines for use of sensitive cohort data.

---


