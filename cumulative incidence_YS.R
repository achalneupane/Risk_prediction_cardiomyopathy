rm(list=ls())
if (as.character(Sys.info()['sysname']) == "Windows"){
  root = 'Z:/ResearchHome/' # for Windows
} else {
  root = '/Volumes/' # for MAC
}
setwd(paste0(root, '/Revised'))

library(survival)
library(survminer)
library(cmprsk)
library(ggplot2)
library(ggsurvfit)
library(dplyr)
library(stringr)
library(readr)
library(tidycmprsk)
library(readxl)
require(gridExtra)

custom_theme = theme(panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(),
                     panel.border = element_blank(),
                     axis.line = element_line(color="black", linewidth=0.7),
                     legend.position = c(0.2,0.8), #Legend position relative to the plot, may need to adjust according to different plots
                     text = element_text(family="Arial"), 
                     plot.margin = margin(5, 5, 10, 5)) #Margins around plot. margin(top, right, bottom,left), use to move risktable

df=read.csv("cum_df.csv")
df[1:5,]
df$sjlid[df$sjlid==""] = df$ccssid[df$sjlid==""]

# Load data for final model (Model 13 with 2 PRSs)
final_model = read_xlsx('figure_2_all_CV_FULL.xlsx', sheet = "Model_13")
final_model$sjlid[is.na(final_model$sjlid)] = final_model$ccssid[is.na(final_model$sjlid)]
# Remove follow-up years which is used as an offset in the model
fup_years = read.csv('follow_years.csv')
fup_years$sjlid[is.na(fup_years$sjlid)] = fup_years$ccssid[is.na(fup_years$sjlid)]
fup_years$ccssid = fup_years$source = NULL
final_model = merge(final_model, fup_years, by='sjlid')
final_model$pred_est_wo_offset = final_model$pred_est/final_model$follow_years
final_model_tx = final_model[c('sjlid', 'anthracyclines_dose_5', 'HeartAvg', 'eve_Cardiomyopathy', 'pred_est', 'pred_est_wo_offset')]

df = merge(df, final_model_tx, by='sjlid')
df = subset(df, gp!=4)

# Model 13-based risk groups
cutoff_hr = 0.1
cutoff_lr = 0.05
df$risk_groups_pred = NA
df$risk_groups_pred[df$pred_est_wo_offset>cutoff_hr] = "High"
df$risk_groups_pred[df$pred_est_wo_offset<cutoff_lr] = "Low"
df$risk_groups_pred[df$pred_est_wo_offset<=cutoff_hr & df$pred_est_wo_offset>=cutoff_lr] = "Moderate"

df$gp[df$gp=="IGHG-high-risk"] = "High"
df$gp[df$gp=="IGHG-moderate-risk"] = "Moderate"
df$gp[df$gp=="IGHG-low-risk"] = "Low"

df = df %>% mutate(gp_n = case_when(gp=="High"~1, gp=="Moderate"~2, gp=="Low"~3))
df = df %>% mutate(risk_groups_pred_n = case_when(risk_groups_pred=="High"~1, risk_groups_pred=="Moderate"~2, risk_groups_pred=="Low"~3))

# SJLIFE
df2 = subset(df, source=="stjd")
prop.table(table(df2$gp, df2$eve_Cardiomyopathy), 1)
prop.table(table(df2$risk_groups_pred, df2$eve_Cardiomyopathy), 1)
# CCSS
df3 = subset(df, source=="ccss")
prop.table(table(df3$gp, df3$eve_Cardiomyopathy), 1)
prop.table(table(df3$risk_groups_pred, df3$eve_Cardiomyopathy), 1)

# CIF according to IGHG-risk groups
# SJLIFE
# df2 = subset(df, source=="stjd")
# prop.table(table(df2$gp, df2$eve_Cardiomyopathy), 1)
# df2$gp = factor(df2$gp, levels=c('High', 'Moderate', 'Low'))
m3=tidycmprsk::cuminc(Surv(years, as.factor(ci_even)) ~ gp_n, df2)
p3= ggcuminc(m3, outcome = c("1"),linetype_aes = TRUE) +
  xlab("Time since baseline, years") +  ylab("Cumulative incidence")+
  coord_cartesian(xlim = c(0,10), ylim = c(0, 0.3))+
  add_risktable(theme = list(theme_risktable_default(), scale_y_discrete(label=c('Low', 'Moderate', 'High')))) +
  scale_ggsurvfit()+
  add_pvalue(location = "annotation", x=1, y=0.12)+
  add_confidence_interval() + 
  add_legend_title('IGHG-based risk groups in SJLIFE') +
  scale_color_manual(values=c("1"="red","2"="blue","3"="green"), labels=c("High", "Moderate", "Low")) +
  scale_linetype_manual(values=c("1"=1,"2"=2,"3"=3), labels=c("High", "Moderate", "Low")) +
  scale_fill_manual(values=c("1"="red","2"="blue","3"="green"), labels=c("High", "Moderate", "Low")) +
  custom_theme
p3
ggsave("cif_ighg_sjlife.png", plot=p3, dpi=300, width=7.5, height=7)
# CCSS
# df3 = subset(df, source=="ccss")
# prop.table(table(df3$gp, df3$eve_Cardiomyopathy), 1)
m4=tidycmprsk::cuminc(Surv(years, as.factor(ci_even)) ~ gp_n, df3)
p4 = ggcuminc(m4, outcome = c("1"),linetype_aes = TRUE) +
  xlab("Time since baseline, years") +  ylab("Cumulative incidence")+
  coord_cartesian(xlim = c(0,10), ylim = c(0, 0.1))+
  add_risktable(theme = list(theme_risktable_default(), scale_y_discrete(label=c('Low', 'Moderate', 'High')))) +
  scale_ggsurvfit()+
  add_pvalue("annotation", x=1, y=0.06)+
  add_confidence_interval() + 
  add_legend_title('IGHG-based risk groups in CCSS') +
  scale_color_manual(values=c("1"="red","2"="blue","3"="green"), labels=c("High", "Moderate", "Low")) +
  scale_linetype_manual(values=c("1"=1,"2"=2,"3"=3), labels=c("High", "Moderate", "Low")) +
  scale_fill_manual(values=c("1"="red","2"="blue","3"="green"), labels=c("High", "Moderate", "Low")) +
  custom_theme
p4
ggsave("cif_ighg_ccss.png", plot=p4, dpi=300, width=7.5, height=7)
# CIF according to Model 13-based risk groups
# SJLIFE
# df2 = subset(df, source=="stjd")
# prop.table(table(df2$risk_groups_pred, df2$eve_Cardiomyopathy), 1)
m3=tidycmprsk::cuminc(Surv(years, as.factor(ci_even)) ~ risk_groups_pred_n, df2)
p3 = ggcuminc(m3, outcome = c("1"),linetype_aes = TRUE) +
  xlab("Time since baseline, years") +  ylab("Cumulative incidence")+
  coord_cartesian(xlim = c(0,10), ylim = c(0, 0.3))+
  add_risktable(theme = list(theme_risktable_default(), scale_y_discrete(label=c('Low', 'Moderate', 'High')))) +
  scale_ggsurvfit()+
  add_pvalue("annotation", x=1, y=0.12)+
  add_confidence_interval() + 
  add_legend_title('Model-based risk groups in SJLIFE') +
  scale_color_manual(values=c("1"="red","2"="blue","3"="green"), labels=c("High", "Moderate", "Low")) +
  scale_linetype_manual(values=c("1"=1,"2"=2,"3"=3), labels=c("High", "Moderate", "Low")) +
  scale_fill_manual(values=c("1"="red","2"="blue","3"="green"), labels=c("High", "Moderate", "Low")) +
  custom_theme
p3
ggsave("cif_model_sjlife.png", plot=p3, dpi=300, width=7.5, height=7)
# CCSS
# df3 = subset(df, source=="ccss")
m4=tidycmprsk::cuminc(Surv(years, as.factor(ci_even)) ~ risk_groups_pred_n, df3)
p4 = ggcuminc(m4, outcome = c("1"),linetype_aes = TRUE) +
  xlab("Time since baseline, years") +  ylab("Cumulative incidence")+
  coord_cartesian(xlim = c(0,10), ylim = c(0, 0.1))+
  add_risktable(theme = list(theme_risktable_default(), scale_y_discrete(label=c('Low', 'Moderate', 'High')))) +
  scale_ggsurvfit()+
  add_pvalue("annotation", x=1, y=0.06)+
  add_confidence_interval() + 
  add_legend_title('Model-based risk groups in CCSS') +
  scale_color_manual(values=c("1"="red","2"="blue","3"="green"), labels=c("High", "Moderate", "Low")) +
  scale_linetype_manual(values=c("1"=1,"2"=2,"3"=3), labels=c("High", "Moderate", "Low")) +
  scale_fill_manual(values=c("1"="red","2"="blue","3"="green"), labels=c("High", "Moderate", "Low")) +
  custom_theme 
p4
ggsave("cif_model_ccss.png", plot=p4, dpi=300, width=7.5, height=7)