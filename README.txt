# Risk Prediction for Cardiomyopathy in Childhood Cancer Survivors

This repository contains R scripts and data used to evaluate and visualize cumulative incidence of cardiomyopathy among survivors of childhood cancer using both **IGHG-based** and **Model 13-based** risk stratification. The analyses leverage data from two major survivor cohorts: **St. Jude Lifetime Cohort (SJLIFE)** and **Childhood Cancer Survivor Study (CCSS)**.

## Overview

The central aim is to assess risk prediction of cardiomyopathy using:

* IGHG (International Guideline Harmonization Group) clinical risk groups
* A multivariable model (Model 13) incorporating clinical and genetic predictors, including polygenic risk scores (PRSs)

Cumulative incidence functions (CIFs) are estimated and compared across risk strata using competing risks methodology.

---

## Repository Structure

### Key Scripts

* `cumulative_incidence_Model4_race.R`: Main script for cumulative incidence analysis and visualization.

### Input Data Files

* `cum_df.csv`: Clinical and genetic data for individuals including event status, risk group, and source (SJLIFE or CCSS).
* `figure_2_all_CV_FULL.xlsx`: Contains Model 13 prediction outputs including estimated cardiomyopathy risk.
* `follow_years.csv`: Contains follow-up years per individual used for rate adjustment.

---

## Analysis Workflow

### 1. Setup

The script automatically detects the OS and sets the working directory:

```r
if (as.character(Sys.info()['sysname']) == "Windows"){
  root = 'Z:/ResearchHome/' # Windows path
} else {
  root = '/Volumes/' # Mac path
}
setwd(paste0(root, '/Revised'))
```

### 2. Loading Required Packages

Key R packages used:

* `tidycmprsk`, `survival`, `ggsurvfit`, `survminer`: Competing risks analysis and Kaplan-Meier style visualization.
* `ggplot2`, `dplyr`, `stringr`, `readr`, `readxl`: Data wrangling and plotting.
* `gridExtra`: For combining plots.

### 3. Data Integration

* Merges `cum_df.csv`, model output (`figure_2_all_CV_FULL.xlsx`), and follow-up times (`follow_years.csv`) by unique subject ID (`sjlid`).
* Calculates predicted risk per year:

  ```r
  final_model$pred_est_wo_offset = final_model$pred_est / final_model$follow_years
  ```

### 4. Risk Stratification

Two types of risk groups are created:

* **IGHG-based risk groups**: Clinically assigned groups labeled as Low, Moderate, High.
* **Model 13-based risk groups**: Assigned based on predicted risk per year:

  * High: >0.1
  * Low: <0.05
  * Moderate: Between 0.05 and 0.1

### 5. Competing Risk Analysis

* Uses `tidycmprsk::cuminc()` to estimate cumulative incidence with death as a competing risk.
* Events are defined in variable `ci_even` and time is in `years`.

### 6. Stratified Analyses

Analyses are performed separately by cohort:

* **SJLIFE (`source == "stjd"`)**
* **CCSS (`source == "ccss"`)**

For each cohort:

* CIFs are plotted across both IGHG and Model 13 risk groups
* `ggcuminc()` used for plotting with:

  * Risk tables
  * Confidence intervals
  * Log-rank p-values
  * Color, linetype, and fill aesthetics for group comparison

---

## Output Figures

Four cumulative incidence plots are saved as `.png` files:

| Plot Description                    | Output File Name       |
| ----------------------------------- | ---------------------- |
| IGHG-based risk groups (SJLIFE)     | `cif_ighg_sjlife.png`  |
| IGHG-based risk groups (CCSS)       | `cif_ighg_ccss.png`    |
| Model 13-based risk groups (SJLIFE) | `cif_model_sjlife.png` |
| Model 13-based risk groups (CCSS)   | `cif_model_ccss.png`   |

All figures are saved at 300 DPI, 7.5x7 inches, and include risk tables and annotations.

---

## Statistical Details

### Competing Risk Model

* CIF estimated using `tidycmprsk::cuminc()`, based on Fine-Gray subdistribution hazards.
* Competing risk: Non-cardiomyopathy death
* Formula: `Surv(years, as.factor(ci_even)) ~ group`

### Risk Group Comparison

* Cumulative incidence curves are compared across IGHG and Model 13 groups.
* `add_pvalue()` adds p-value from Gray’s test comparing cumulative incidence curves across groups.

---

## Requirements

### R version

Tested on R 4.3.0+

### Required packages

```r
install.packages(c("survival", "survminer", "ggplot2", "dplyr", "readr", "readxl", "stringr", "gridExtra", "ggsurvfit"))
# From CRAN or GitHub:
remotes::install_github("ddsjoberg/tidycmprsk")
```

---

## Notes

* IGHG group assignment is mapped from categorical variable `gp`
* Model 13 groups are based on a fixed cutoff of predicted cardiomyopathy risk
* Individuals with `gp == 4` are excluded
* Both `sjlid` and `ccssid` IDs are used for merging datasets

---
