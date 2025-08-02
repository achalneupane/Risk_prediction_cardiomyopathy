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

# Load data for final model (Model 13 with 2 PRSs)
final_model = read_xlsx('figure_2_all_CV_FULL.xlsx', sheet = "Model_13")
final_model$sjlid[is.na(final_model$sjlid)] = final_model$ccssid[is.na(final_model$sjlid)]

## Generate calibration plots
final_model_sjlife = subset(final_model, source=="stjd")
final_model_ccss = subset(final_model, source=="ccss")

# Yutaka suggested the following
# 1) Group people into the deciles of the predicted probability (1- exp(- pred_est)).
# 2) In each decile group, calculate the event proportion.
# 3) Plot (x = median of the predicted probability of the decile group, y = the event proportion of the decile group from 2)).  That is, there will be 10 points.
# 4) If they are close to the y=x line, then we have a good calibration.
# 5) To make a little fancy, you could overlay the histogram of the observations just above the x-axis like the plot you made.
pdf('Model_calibration_plots_revised_based_on_Yutaka.pdf')
# pdf('Model_calibration_plots_revised_based_on_Yutaka.pdf', width = 12, height = 7)
# par(mfrow=c(1,2))
par(mfrow=c(1,1))
# # SJLIFE
# dat = final_model_sjlife
# dat$prob = 1-exp(-dat$pred_est)
# dat$prob_deciles = cut(dat$prob, breaks = quantile(dat$prob, probs=seq(0,1,.1)), include.lowest=T)
# dat_prop = data.frame(cat = as.factor(names(prop.table(table(dat$prob_deciles, dat$eve_Cardiomyopathy))[,2])),
#                       prop = prop.table(table(dat$prob_deciles, dat$eve_Cardiomyopathy),1)[,2])
# prob_deciles_median = aggregate(prob~prob_deciles, data=data.frame(dat), median)
# dat_prop = cbind(dat_prop, prob_deciles_median)
# plot.default(x=dat_prop$prob, y=dat_prop$prop, type='p', xlab = "Predicted Probability", ylab = "Actual Probability", main = 'St. Jude Lifetime Cohort')
# lines(x=dat_prop$prob, y=dat_prop$prop)
# # Add a 45 degree line
# abline(a=0, b=1, col="blue")
# CCSS
dat = final_model_ccss
dat$prob = 1-exp(-dat$pred_est)
dat$prob_deciles = cut(dat$prob, breaks = quantile(dat$prob, probs=seq(0,1,.1)), include.lowest=T)
dat_prop = data.frame(cat = as.factor(names(prop.table(table(dat$prob_deciles, dat$eve_Cardiomyopathy))[,2])),
                      prop = prop.table(table(dat$prob_deciles, dat$eve_Cardiomyopathy),1)[,2])
prob_deciles_median = aggregate(prob~prob_deciles, data=data.frame(dat), median)
dat_prop = cbind(dat_prop, prob_deciles_median)
plot.default(x=dat_prop$prob, y=dat_prop$prop, type='p', xlim = c(0, 0.09), ylim = c(0,0.09),
             xlab = "Predicted Probability", ylab = "Actual Probability", main = 'Childhood Cancer Survivor Study')
lines(x=dat_prop$prob, y=dat_prop$prop)
# Add a 45 degree line
abline(a=0, b=1, col="blue")
dev.off()