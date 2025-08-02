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

## IGHG risk groups
clinical_age$risk_groups = NA
clinical_age$risk_groups[clinical_age$anthracyclines_dose_5>=250 | clinical_age$HeartAvg>=3000 | 
                             (clinical_age$anthracyclines_dose_5>=100 & clinical_age$HeartAvg>=1500)] = "high_risk"
clinical_age$risk_groups[(clinical_age$anthracyclines_dose_5>100 & clinical_age$anthracyclines_dose_5<250 & is.na(clinical_age$risk_groups)) | 
                             (clinical_age$HeartAvg>1500 & clinical_age$HeartAvg<3000 & is.na(clinical_age$risk_groups))] = "moderate_risk"
clinical_age$risk_groups[(clinical_age$anthracyclines_dose_5>0 & clinical_age$anthracyclines_dose_5<=100 & is.na(clinical_age$risk_groups)) | 
                             (clinical_age$HeartAvg>0 & clinical_age$HeartAvg<=1500 & is.na(clinical_age$risk_groups))] = "low_risk"
clinical_age$risk_groups[clinical_age$anthracyclines_dose_5==0 & clinical_age$HeartAvg==0] = "Unexposed"

# Explore cutoffs based on predicted rates and create new risk groups
# Use only exposed survivors from the final model
clinical_age = subset(clinical_age, gp!=4)
# High-risk
cutoff_hr = median(clinical_age$pred_est[clinical_age$gp==1 & clinical_age$source=="stjd" & clinical_age$eve_Cardiomyopathy==0])
cutoff_hr = 0.08
# Low-risk
cutoff_lr = median(clinical_age$pred_est[clinical_age$gp==2 & clinical_age$source=="stjd" & clinical_age$eve_Cardiomyopathy==0])
cutoff_lr = 0.02
clinical_age$gp_pred = NA
clinical_age$gp_pred[clinical_age$pred_est>cutoff_hr] = "high_risk"
clinical_age$gp_pred[clinical_age$pred_est<cutoff_lr & clinical_age$gp!=4] = "low_risk"
clinical_age$gp_pred[clinical_age$pred_est<=cutoff_hr & clinical_age$pred_est>=cutoff_lr] = "moderate_risk"
# Survivors in SJLIFE
table(clinical_age$gp[clinical_age$source=='stjd'], clinical_age$gp_pred[clinical_age$source=='stjd'])
# Observed CMP rates in SJLIFE
round(prop.table(table(clinical_age$gp[clinical_age$source=='stjd'], clinical_age$eve_Cardiomyopathy[clinical_age$source=='stjd']), 1)*100, 1) # Current IGHG groups
round(prop.table(table(clinical_age$gp_pred[clinical_age$source=='stjd'], clinical_age$eve_Cardiomyopathy[clinical_age$source=='stjd']), 1)*100, 1) # New risk groups
# Survivors in CCSS
table(clinical_age$gp[clinical_age$source=='ccss'], clinical_age$gp_pred[clinical_age$source=='ccss'])
# Observed CMP rates in SJLIFE
round(prop.table(table(clinical_age$gp[clinical_age$source=='ccss'], clinical_age$eve_Cardiomyopathy[clinical_age$source=='ccss']), 1)*100, 1) # Current IGHG groups
round(prop.table(table(clinical_age$gp_pred[clinical_age$source=='ccss'], clinical_age$eve_Cardiomyopathy[clinical_age$source=='ccss']), 1)*100, 1) # New risk groups
# Survivors in CCSS


## Boxplot
# Use the final model "clinical_age"
dat = clinical_age
dat$gp = factor(dat$gp, levels = c(1, 2, 3, 4), labels = c("High\nrisk", "Moderate\nrisk", "Low\nrisk", "Unexposed"))
dat$eve_Cardiomyopathy[dat$eve_Cardiomyopathy=="0"] = "Survivors without cardiomyopathy"
dat$eve_Cardiomyopathy[dat$eve_Cardiomyopathy=="1"] = "Survivors with cardiomyopathy"
dat$source = factor(dat$source, levels = c('stjd', 'ccss'), labels = c("St. Jude Lifetime Cohort", "Childhood Cancer Survivor Study"))

# pdf('Boxplots_pred_log_odds_best_model_IGHG_risk_groups_revised.pdf', width = 10, height = 7)
dat$pred_est = ifelse(dat$pred_est>0.3, 0.3, dat$pred_est)
# dat = subset(dat, pred_est<1)
ggplot(dat, aes(x=gp, y=pred_est, fill=eve_Cardiomyopathy)) +
  facet_wrap(.~source) +
  geom_boxplot() +
  labs(y="Predicted rates",x="") +
  theme_bw() + 
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        text = element_text(size=15,colour="black"), 
        axis.text = element_text(colour = "black", size = 15)) + 
  geom_hline(yintercept = cutoff_hr, color='red') + 
  geom_hline(yintercept = cutoff_lr, color='green')
  # geom_hline(yintercept = -2.993, color = 'blue', linetype='dotted', size=0.5) +
  # geom_hline(yintercept = -2.302585, color = 'blue', linetype='dashed', size=0.5) +
  # geom_hline(yintercept = -1.89712, color = 'blue', linetype='solid', size=0.5) +
  # geom_hline(yintercept = -3.9785, color = 'green', linetype='dotted', size=0.5) +
  # geom_hline(yintercept = -4.199705, color = 'green', linetype='dashed', size=0.5) +
  # geom_hline(yintercept = -4.60517, color = 'green', linetype='solid', size=0.5)
# dev.off()
