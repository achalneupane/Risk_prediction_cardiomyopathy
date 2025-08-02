## Phenotype data for SJLIFE
rm(list=ls())
if (as.character(Sys.info()['sysname']) == "Windows"){
  root = 'Z:/ResearchHome/' # for Windows
} else {
  root = '/Volumes/' # for MAC
}
setwd(paste0(root, '/Revised'))

library(tidyr)
library(readxl)
library(ggplot2)
# install.packages('CalibrationCurves')
library(CalibrationCurves)
library(rms)


## Load predicted probabilities and observed outcomes of all models from Yan
# Clinical (Model 1)
clinical = read_xlsx('figure_2_all_CV_FULL.xlsx', sheet = "Model_1")
# Clinical plus age at baseline (Model 2)
clinical_age = read_xlsx('figure_2_all_CV_FULL.xlsx', sheet = "Model_2")
# Clinical plus age at baseline plus htn (Model 3)
clinical_age_htn = read_xlsx('figure_2_all_CV_FULL.xlsx', sheet = "Model_3")
# Clinical plus age at baseline plus htn plus ancestry (Model 5)
clinical_age_htn_ancestry = read_xlsx('figure_2_all_CV_FULL.xlsx', sheet = "Model_5")
# Clinical plus age at baseline plus htn plus ancestry plus all PRSs (Model 13)
clinical_age_htn_ancestry_allprs = read_xlsx('figure_2_all_CV_FULL.xlsx', sheet = "Model_13")

## Generate calibration plots
# SJLIFE
clinical_sjlife = subset(clinical, source=="stjd")
clinical_ccss = subset(clinical, source=="ccss")
clinical_age_sjlife = subset(clinical_age, source=="stjd")
clinical_age_ccss = subset(clinical_age, source=="ccss")
clinical_age_htn_sjlife = subset(clinical_age_htn, source=="stjd")
clinical_age_htn_ccss = subset(clinical_age_htn, source=="ccss")
clinical_age_htn_ancestry_sjlife = subset(clinical_age_htn_ancestry, source=="stjd")
clinical_age_htn_ancestry_ccss = subset(clinical_age_htn_ancestry, source=="ccss")
clinical_age_htn_ancestry_allprs_sjlife = subset(clinical_age_htn_ancestry_allprs, source=="stjd")
clinical_age_htn_ancestry_allprs_ccss = subset(clinical_age_htn_ancestry_allprs, source=="ccss")

# # Calibration plots
# pdf('Model_calibration_plots.pdf', width=12, height=8)
# par(mfrow=c(1,2))
# clinical_sjlife_cal = rms::val.prob((1-exp(-clinical_sjlife$pred_est)), clinical_sjlife$eve_Cardiomyopathy)
# clinical_ccss_cal = rms::val.prob((1-exp(-clinical_ccss$pred_est)), clinical_ccss$eve_Cardiomyopathy)
# clinical_age_sjlife_cal = rms::val.prob((1-exp(-clinical_age_sjlife$pred_est)), clinical_age_sjlife$eve_Cardiomyopathy)
# clinical_age_ccss_cal = rms::val.prob((1-exp(-clinical_age_ccss$pred_est)), clinical_age_ccss$eve_Cardiomyopathy)
# clinical_age_htn_sjlife_cal = rms::val.prob((1-exp(-clinical_age_htn_sjlife$pred_est)), clinical_age_htn_sjlife$eve_Cardiomyopathy)
# clinical_age_htn_ccss_cal = rms::val.prob((1-exp(-clinical_age_htn_ccss$pred_est)), clinical_age_htn_ccss$eve_Cardiomyopathy)
# clinical_age_htn_ancestry_sjlife_cal = rms::val.prob((1-exp(-clinical_age_htn_ancestry_sjlife$pred_est)), clinical_age_htn_ancestry_sjlife$eve_Cardiomyopathy)
# clinical_age_htn_ancestry_ccss_cal = rms::val.prob((1-exp(-clinical_age_htn_ancestry_ccss$pred_est)), clinical_age_htn_ancestry_ccss$eve_Cardiomyopathy)
# clinical_age_htn_ancestry_allprs_sjlife_cat = rms::val.prob((1-exp(-clinical_age_htn_ancestry_allprs_sjlife$pred_est)), clinical_age_htn_ancestry_allprs_sjlife$eve_Cardiomyopathy)
# clinical_age_htn_ancestry_allprs_ccss_cat = rms::val.prob((1-exp(-clinical_age_htn_ancestry_allprs_ccss$pred_est)), clinical_age_htn_ancestry_allprs_ccss$eve_Cardiomyopathy)
# dev.off()

# Yutaka suggested another way
# 1) Group people into the deciles of the predicted probability (1- exp(- pred_est)).
# 2) In each decile group, calculate the event proportion.
# 3) Plot (x = median of the predicted probability of the decile group, y = the event proportion of the decile group from 2)).  That is, there will be 10 points.
# 4) If they are close to the y=x line, then we have a good calibration.
# 5) To make a little fancy, you could overlay the histogram of the observations just above the x-axis like the plot you made.
pdf('Model_calibration_plots_revised_based_on_Yutaka.pdf', width=12, height=8)
par(mfrow=c(1,2))
my_list = list(clinical_sjlife, clinical_ccss,
               clinical_age_sjlife, clinical_age_ccss,
               clinical_age_htn_sjlife, clinical_age_htn_ccss,
               clinical_age_htn_ancestry_sjlife, clinical_age_htn_ancestry_ccss,
               clinical_age_htn_ancestry_allprs_sjlife, clinical_age_htn_ancestry_allprs_ccss)

for (i in 1:length(my_list)){
  dat = my_list[[i]]
  dat$prob = 1-exp(-dat$pred_est)
  dat$prob_deciles = cut(dat$prob, breaks = quantile(dat$prob, probs=seq(0,1,.1)), include.lowest=T)
  dat_prop = data.frame(cat = as.factor(names(prop.table(table(dat$prob_deciles, dat$eve_Cardiomyopathy))[,2])),
                        prop = prop.table(table(dat$prob_deciles, dat$eve_Cardiomyopathy))[,2])
  prob_deciles_median = aggregate(prob~prob_deciles, data=data.frame(dat), median)
  dat_prop = cbind(dat_prop, prob_deciles_median)
  reg = lm(dat_prop$prop~dat_prop$prob)
  coeff = coefficients(reg)
  # eq = paste0("y = ", round(coeff[2],5), "*x ", round(coeff[1],5))
  # dat_prop$cat = factor(seq(0.1,1,0.1))
  plot.default(x=dat_prop$prob, y=dat_prop$prop, type='p', xlab = "Predicted Probability", ylab = "Actual Probability")
  # axis (side=1, at = dat_prop$prob, labels=round(dat_prop$prob,2))
  lines(x=dat_prop$prob, y=dat_prop$prop)
  abline(reg, col='blue')
}
dev.off()