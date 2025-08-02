## Phenotype data for SJLIFE
rm(list=ls())
if (as.character(Sys.info()['sysname']) == "Windows"){
  root = 'Z:/ResearchHome/' # for Windows
} else {
  root = '/Volumes/' # for MAC
}
setwd(paste0(root, '/Revised'))

## Get clinical/demographics data for everyone
library(sas7bdat)
demo = read.sas7bdat('Clinical Data/demographics.sas7bdat')
demo_subset = subset(demo, studypop=="Survivor" & Newstatus==3, 
                     select=c('sjlid', 'gender', 'racegrp'))
diag = read.sas7bdat('Clinical Data/diagnosis.sas7bdat')
diag_subset = subset(diag, studypop=="Survivor" & primdx==1 & Newstatus==3, 
                     select=c('sjlid', 'agedx', 'diaggrp'))
rt = read.sas7bdat('Clinical Data/radiation_dosimetry.sas7bdat')
rt_subset = rt[c('sjlid', 'HeartAvg')]
rt_subset$HeartAvg[rt_subset$HeartAvg==999999.0 | rt_subset$HeartAvg==777777.0] = NA

chemo = read.sas7bdat('Clinical Data/chemosum_dose.sas7bdat')
chemo_subset = chemo[c('sjlid', 'anthracyclines_dose_5', 'anthracyclines_dose_any')]

age = read.sas7bdat('Tracking Data/lstcondt.sas7bdat')
age_subset = age[c('sjlid', 'agelstcontact')]

age_sjlife_baseline = read.table('../SJLIFE_baseline_age.txt', header = TRUE)
age_sjlife_baseline_subset = age_sjlife_baseline[c('sjlid', 'age_baseline', 'age_death')]

## Merge all datasets
library(tidyverse)
dat = merge(demo_subset, diag_subset, by='sjlid')
dat = merge(dat, chemo_subset, by='sjlid', all.x = TRUE)
dat = merge(dat, rt_subset, by='sjlid', all.x = TRUE)
dat = merge(dat, age_subset, by='sjlid', all.x = TRUE)
dat = merge(dat, age_sjlife_baseline_subset, by='sjlid', all.x = TRUE)
save(dat, file = 'sjlife_data_for_cardiomyopathy_prediction_Yan.RData')
