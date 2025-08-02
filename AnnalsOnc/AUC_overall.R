rm(list=ls())
# setwd("/Volumes/clusterhome/ysapkota/Work/Manuscripts/Cardiomyopathy_PRS/FINAL/Revised_analysis/")
setwd("Z:/ResearchHome/clusterhome/ysapkota/Work/Manuscripts/Cardiomyopathy_PRS/FINAL/Revised_analysis/")
library(ggplot2)
# install.packages('patchwork')
library(ggprism)
library(patchwork)
library(magrittr)
library(dplyr)

# AUC estimates for cardiomyopathy
data = read.table('AUC_final_model_with_race.txt', header = TRUE, sep = "\t")
# data$Models = as.factor(data$Models)
# levels(data$Models) = c("Clinical", "Clinical+age", "Clinical+age+hypertension", "Clinical+age+hypertension+ancestry", 
                # "Clinical+age+hypertension+ancestry+PRSs")

## Plot
pdf('AUC_overall_with_race.pdf', width = 11, height = 6.5, bg = "white")
data$Models = as.factor(data$Models)
data$Cohorts = relevel(as.factor(data$Cohorts), ref = 'SJLIFE')
levels(data$Cohorts) = c('St. Jude Lifetime Cohort', 'Childhood Cancer Survivor Study')

# For p-values, format the data which needs group1 and group2 columns
stat_test = data %>% group_by(Models)
stat_test$group1 = rep(c(NA, as.character(stat_test$Models[c(1:3, 3, 5)])), 2)
stat_test$group2 = rep(c(NA, as.character(stat_test$Models[c(2:6)])), 2)
stat_test$y.position = stat_test$U95 + 0.01
# stat_test$y.position[c(4:5, 8:10)] = stat_test$y.position[c(4:5, 8:10)] + c(0.01, 0.02, 0.01, 0.02, 0.03)
stat_test$y.position[c(4:6, 8:12)] = stat_test$y.position[c(4:6, 8:12)] + c(0.02, 0.026, 0.031, -0.001, 0.013, 0.023, 0.038, 0.04)
                                                                            
# Format p-values
# stat_test$P.formatted = as.character(c(NA, "9.0*x*10^-3", "1.1*x*10^-5", 0.47, 0.64, NA, "2.0*x*10^-4", "8.7*x*10^-8", 0.92, 0.68))
                                                                              
pd = position_dodge(0.8)

theme_set(theme_bw(18))

p = ggplot(data = data, aes(x = Models, y=AUC, color=Models,lshape=Models)) + 
  facet_wrap(~Cohorts) +
  geom_point(size=7)+
  geom_errorbar(aes(ymin=L95, ymax=U95), width=0, size=3)+
  geom_text(aes(label=sprintf("%0.3f", round(AUC, digits=3))),hjust=-0.4, vjust=-0.55, angle=0, size=4, show.legend = F)+
  theme_bw()+theme(axis.text = element_text(colour = "black", size = 14),
                   panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(),
                   text = element_text(size=14,colour="black"),
                   legend.position = "top",
                   legend.box = "vertical",
                   legend.key.width = unit(1.1, 'cm'), 
                   legend.title = element_blank(),
                   axis.ticks.x = element_blank(),
                   axis.text.x = element_blank(),
                   axis.title.y = element_text(vjust = +1.5, size = 15)) + 
  guides(color=guide_legend(nrow=2, byrow=TRUE)) +
  labs(y="Area under the ROC curve (95% CI)",x="")

p + add_pvalue(stat_test,label = "P", label.size = 4, parse = TRUE)
dev.off()
