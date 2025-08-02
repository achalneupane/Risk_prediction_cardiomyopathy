# Cardiomyopathy Risk Prediction in Childhood Cancer Survivors

This repository contains R scripts and supporting files for reproducing the statistical analyses and visualizations presented in our publication: [Predicting the 10-year risk of cardiomyopathy](https://www.sciencedirect.com/science/article/pii/S0923753425007689)


## Overview

This analysis evaluates and calibrates predictive models for 10-year cardiomyopathy risk in long-term survivors of childhood cancer from:

* **St. Jude Lifetime Cohort (SJLIFE)**
* **Childhood Cancer Survivor Study (CCSS)**

A Fine-Gray subdistribution hazard model framework is used to estimate cumulative incidence functions (CIFs), accounting for death as a competing risk. Models incorporate clinical risk factors, genetic ancestry, and polygenic risk scores (PRSs).

## Repository Structure & Script Descriptions (Suggested Execution Order)

### 1. `prepare_sjlife_data.R`

Preprocesses SJLIFE phenotype, treatment, and clinical covariate data. It derives variables for cardiomyopathy onset, censoring time, treatment exposure (anthracycline dose, radiation), hypertension, obesity, diabetes, and dyslipidemia.

### 2. `prepare_genetic_data_sjlife_ccss.R`

Merges genotype data including ancestry principal components and standardized polygenic risk scores (PRSs) with clinical data. It harmonizes identifiers across cohorts and filters for high-quality variants.

### 3. `modeling_with_CVRF_dyslip_htn_obesity_t2d_revised_v2_grade2_included_revised_baseline.R`

Fits Fine-Gray competing risks models for cardiomyopathy risk using clinical and genetic covariates. This includes:

* Clinical-only models
* Models with cardiometabolic risk factors
* Models with PRS and ancestry
  Outputs include model coefficients, subdistribution hazard ratios (sHRs), and baseline hazards.

### 4. `cumulative incidence.R`

Calculates cumulative incidence functions using fitted Fine-Gray models. Outputs predicted 10-year risk for each individual using linear predictors.

### 5. `cumulative incidence_YS.R`

Refined implementation that improves estimation of CIFs and adjusts for edge cases. Includes sensitivity to baseline hazards.

### 6. `cumulative incidence_YS_Model4_race.R`

Generates stratified CIFs based on race for Model 4 (clinical + hypertension). Assesses racial disparities in predicted cardiomyopathy risk.

### 7. `model_calibration_revised.R`

Assesses model calibration by grouping survivors into deciles of predicted risk and comparing observed vs predicted 10-year cumulative incidence. Includes Hosmer–Lemeshow-type plots and calibration curves.

### 8. `AUC_overall.R`

Computes model discrimination (AUC) using ROC curves and DeLong’s test to compare AUCs across models. Produces overall and cohort-specific estimates.

### 9. `IGHG_based_analysis.R`, `IGHG_based_analysis_revised.R`, `IGHG_based_analysis_revised_with_prs.R`

Subset analysis for individuals with known immunoglobulin heavy chain gene (IGHG) variants. Tests impact of PRSs and ancestry on model performance within this genetic subgroup.

### 10. `PRS_distribution.R`

Plots distribution of PRSs across ancestry groups and cohorts (SJLIFE, CCSS). Includes density plots, boxplots, and statistical comparisons (e.g., Wilcoxon rank-sum test).

## Output Files

* `Model_calibration_plots.pdf`, `Model_calibration_plots_revised_based_on_YS.pdf`: Visualizations of predicted vs observed risk.
* `AUC_overall.pdf`: ROC and AUC comparison plots across models.
* `figure_2_all_new_13.xlsx`: Data behind primary figure showing risk distribution and outcomes.

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


