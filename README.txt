# Cardiomyopathy Risk Prediction in Childhood Cancer Survivors

This repository contains R scripts and supporting files for reproducing the statistical analyses and visualizations presented in the manuscript:

**Citation:**

> K. Petrykey, Y. Chen, A. Neupane, J.N. French, H. Wang, H. Xiang, S.B. Dixon, C. Vukadinovich, C. Im, M.J. Ehrhardt, D.A. Mulrooney, N. Sharafeldin, X. Wang, R.M. Howell, J.L. Jefferies, P.W. Burridge, K.C. Oeffinger, M.M. Gramatges, S. Bhatia, L.L. Robison, K.K. Ness, M.M. Hudson, E.J. Chow, G.T. Armstrong, Y. Yasui, Y. Sapkota. *Predicting the 10-year risk of cardiomyopathy in long-term survivors of childhood cancer*, Annals of Oncology, 2025.

## Overview

This analysis focuses on evaluating and calibrating predictive models of cardiomyopathy risk using data from two major cohorts:

* **St. Jude Lifetime Cohort (SJLIFE)**
* **Childhood Cancer Survivor Study (CCSS)**

The objective is to predict the 10-year risk of cardiomyopathy in long-term childhood cancer survivors using a Fine-Gray competing risk model framework. The models incorporate clinical risk factors, genetic predictors (polygenic risk scores), and ancestry.

## Repository Structure

* `model_calibration_revised.R`: Generates calibration plots for Model 13 (final model with 2 PRSs).
* `AUC_overall.R`: Plots area under the curve (AUC) estimates with 95% confidence intervals and p-values across models.
* `figure_2_all_new_13.xlsx`: Contains predicted estimates, true events, and identifiers for SJLIFE and CCSS.
* `AUC_final_model_with_race.txt`: AUC data for each model across cohorts.

## Methods and Statistical Analysis

### 1. **Model Development**

* Fine-Gray subdistribution hazard model was used to estimate 10-year cumulative incidence functions (CIFs) for cardiomyopathy, accounting for death as a competing risk.
* Predictors were selected based on clinical relevance and prior evidence. These included:

  * Demographic and treatment factors
  * Hypertension status
  * Genetic ancestry
  * Two polygenic risk scores (PRS): derived from published GWAS

### 2. **Calibration Analysis** (`model_calibration_revised.R`)

* Each individual’s predicted 10-year cardiomyopathy risk was transformed as `1 - exp(-pred_est)` to estimate CIF.
* Individuals were grouped into deciles based on predicted probability.
* Within each decile, the observed proportion of cardiomyopathy events (`eve_Cardiomyopathy`) was calculated.
* A scatter plot of predicted vs. observed probabilities was created.
* Overlay includes a 45° line (perfect calibration).

### 3. **Discrimination (AUC) Analysis** (`AUC_overall.R`)

* Area under the ROC curve (AUC) was computed for each model.
* AUC estimates and 95% confidence intervals were plotted for each cohort (SJLIFE and CCSS).
* P-values for pairwise comparisons between sequential models were annotated.
* Models include combinations of clinical variables, age, hypertension, ancestry, and PRSs.

### 4. **Statistical Tools**

* Plots were generated using `ggplot2`, `ggprism`, and `patchwork`.
* Calibration used quantile-based binning.
* Discrimination was evaluated using logistic regression-based AUC estimation with paired p-values.

## Output

* `Model_calibration_plots_revised_based_on_YS.pdf`: Calibration plots for CCSS cohort.
* `AUC_overall_with_race.pdf`: Discrimination plot comparing model performance.

## Required R Packages

```R
install.packages(c("tidyr", "readxl", "ggplot2", "CalibrationCurves", "rms", "ggprism", "patchwork", "magrittr", "dplyr"))
```

## How to Run

1. Set the working directory appropriately depending on your OS:

   * Windows: `Z:/ResearchHome/`
   * macOS: `/Volumes/`
2. Run `model_calibration_revised.R` to generate calibration plots.
3. Run `AUC_overall.R` to generate AUC plots.

## Notes

* `Model_13` refers to the final model used in the manuscript.
* Some files (e.g., `figure_2_all_new_13.xlsx`) are cohort-specific and must be accessible in the working directory.
* For confidentiality, sensitive data must be handled following IRB guidelines.

---
