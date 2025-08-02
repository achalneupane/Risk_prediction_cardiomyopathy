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

## Load PRS data
load('genetic_data_sjlife_ccss_for_cardiomyopathy_prediction_Yan_revised.RData')
colnames(dat.ccss)[1] = 'sjlid'
prs = rbind(dat.sjlife, dat.ccss)

## Load final data from Yan
final_dat = read_xlsx('figure_2_all.xlsx', sheet = "Model_1")
final_dat$sjlid[is.na(final_dat$sjlid)] = final_dat$ccssid[is.na(final_dat$sjlid)]

## Add PRSs
final_dat_prs = merge(final_dat, prs, by='sjlid')
library(ggplot2)
ggplot(final_dat_prs, aes((SCORE_LVESVi), fill=source)) + geom_density(alpha = 0.2)

## Check PRS from the entire SJLIFE and CCSS
# SJLIFE
LVESVi_sjlife = read.table('../Pirruccello_Nat_Comm_LVESVi_hg38.txt_harmonized_revised_prs_sjlife_revised.all_score', header = TRUE)
LVESVi_sjlife = LVESVi_sjlife[c('IID', 'Pt_1')]
colnames(LVESVi_sjlife)[2] = 'SCORE_LVESVi'
LVESVi_sjlife$cohort = 'stjd'
# CCSS
LVESVi_exp = read.table('../Pirruccello_Nat_Comm_LVESVi_hg38.txt_harmonized_revised_prs_ccss_exp_revised.all_score', header = TRUE)
LVESVi_exp = LVESVi_exp[c('IID', 'Pt_1')]
LVESVi_org = read.table('../Pirruccello_Nat_Comm_LVESVi_hg19.txt_harmonized_prs_ccss_org.all_score', header = TRUE)
LVESVi_org = LVESVi_org %>% separate(IID, c('FID', 'IID'), sep = "_")
LVESVi_org = LVESVi_org[c('IID', 'Pt_1')]
LVESVi_ccss = rbind(LVESVi_exp, LVESVi_org)
LVESVi_ccss = LVESVi_exp
colnames(LVESVi_ccss)[2] = 'SCORE_LVESVi'
LVESVi_ccss$cohort = 'ccss'
LVESVi_all = rbind(LVESVi_sjlife, LVESVi_ccss)
ggplot(LVESVi_all, aes(scale(SCORE_LVESVi), fill=cohort)) + geom_density(alpha = 0.2)
