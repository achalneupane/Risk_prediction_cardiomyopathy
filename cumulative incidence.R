library(survival)
library(survminer)
library(cmprsk)

library(ggplot2)
library(ggsurvfit)
library(dplyr)
library(stringr)
library(readr)

library(tidycmprsk)

custom_theme = theme(panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(),
                     panel.border = element_blank(),
                     axis.line = element_line(color="black", linewidth=0.7),
                     legend.position = c(0.2,0.8), #Legend position relative to the plot, may need to adjust according to different plots
                     text = element_text(family="Arial"), 
                     plot.margin = margin(5, 5, 10, 5)) #Margins around plot. margin(top, right, bottom,left), use to move risktable

df=read.csv("z:\\SJShare\\SJCOMMON\\ECC\\Biostat\\Yan\\STLIFE\\Yan\\Yadav ROC\\results\\prepare paper\\cum_df.csv")
df[1:5,]
#CIF according to population
m3=tidycmprsk::cuminc(Surv(years, as.factor(ci_even)) ~ source, df)
p3= ggcuminc(m3, outcome = c("1"),linetype_aes = TRUE) +
  xlab("Age in years") +  ylab("Cumulative incidence")+
  coord_cartesian(xlim = c(0,12))+
  add_risktable() +
  scale_ggsurvfit()+
  add_pvalue("annotation", x=15.5, y=0.07)+
  custom_theme
p3
ggsave("cif_pop.png", plot=p3, dpi=300, width=7, height=7)