## Phenotype data for SJLIFE
rm(list=ls())
if (as.character(Sys.info()['sysname']) == "Windows"){
  root = 'Z:/ResearchHome/' # for Windows
} else {
  root = '/Volumes/' # for MAC
}
setwd(paste0(root, '/Revised'))

library(tidyr)

## SJLIFE ################
##########################
sjlife_ancestry =  read.table(paste0(root, 'clusterhome/ysapkota/Work/sjlife_1_n_2/ancestry/sjlife_wgs_admixture.txt'), header = TRUE)
sjlife_ancestry$genet_ancestry = ifelse(sjlife_ancestry$AFR>0.6, 'AFR', ifelse(sjlife_ancestry$EUR>0.8, 'EUR', 'others'))
sjlife_ancestry$genet_ancestry = relevel(as.factor(sjlife_ancestry$genet_ancestry), ref = "EUR")
sjlife_ancestry = sjlife_ancestry[c('sjlid','genet_ancestry')]
# DCM
DCM_tadros = read.table('../DCM_Tadros_Nat_Genet_hg38.txt_harmonized_prs_sjlife.all_score', header = TRUE)
DCM_tadros = DCM_tadros[c('IID', 'Pt_1')]
colnames(DCM_tadros)[2] = 'SCORE_DCM_tadros'
# HCM
HCM_tadros = read.table('../PGS000778_Tadros_Nat_Genet_HCM_hg38.txt_harmonized_prs_sjlife.all_score', header = TRUE)
HCM_tadros = HCM_tadros[c('IID', 'Pt_1')]
colnames(HCM_tadros)[2] = 'SCORE_HCM_tadros'
# LVEF
LVEF_pirruccello = read.table('../Pirruccello_Nat_Comm_LVEF_hg38.txt_harmonized_prs_sjlife.all_score', header = TRUE)
LVEF_pirruccello = LVEF_pirruccello[c('IID', 'Pt_1')]
colnames(LVEF_pirruccello)[2] = 'SCORE_LVEF_pirruccello'
# LVESVi
LVESVi = read.table('../Pirruccello_Nat_Comm_LVESVi_hg38.txt_harmonized_revised_prs_sjlife_revised.all_score', header = TRUE)
LVESVi = LVESVi[c('IID', 'Pt_1')]
colnames(LVESVi)[2] = 'SCORE_LVESVi'
# ACT
ACT = read.table('../Cardiomyopathy_survivors_studies_hg38.txt_harmonized_prs_sjlife.all_score', header = TRUE)
ACT = ACT[c('IID', 'Pt_1')]
colnames(ACT)[2] = 'SCORE_ACT'
# HF
HF = read.table('../PGS001790_Wang_medRxiv_HF_hg38.txt_harmonized_prs_sjlife.all_score', header = TRUE)
HF = HF[c('IID', 'Pt_1')]
colnames(HF)[2] = 'SCORE_HF'
prs_list = list(DCM_tadros, HCM_tadros, LVEF_pirruccello, LVESVi, ACT, HF)
all_prs.sjlife = Reduce(function(x, y) merge(x, y, all=TRUE), prs_list)
# Merge ancestry and PRS
dat.sjlife = merge(sjlife_ancestry, all_prs.sjlife, by.x = 'sjlid', by.y = 'IID')

## CCSS ##################
##########################
ccss_ancestry = read.delim('../CCSS_data_cmp.txt', header = TRUE, sep = "\t")
ccss_ancestry$genet_ancestry = ifelse(ccss_ancestry$YRI>0.6, 'AFR', ifelse(ccss_ancestry$CEU>0.8, 'EUR', 'others'))
ccss_ancestry = ccss_ancestry[c('ccssid','genet_ancestry')]
# DCM
DCM_exp_tadros = read.table('../DCM_Tadros_Nat_Genet_hg38.txt_harmonized_prs_ccss_exp.all_score', header = TRUE)
DCM_exp_tadros = DCM_exp_tadros[c('IID', 'Pt_1')]
DCM_org_tadros = read.table('../DCM_Tadros_Nat_Genet_hg19.txt_harmonized_prs_ccss_org.all_score', header = TRUE)
DCM_org_tadros = DCM_org_tadros %>% separate(IID, c('FID', 'IID'), sep = "_")
DCM_org_tadros = DCM_org_tadros[c('IID', 'Pt_1')]
DCM_tadros = rbind(DCM_exp_tadros, DCM_org_tadros)
colnames(DCM_tadros)[2] = 'SCORE_DCM_tadros'
# HCM
HCM_tadros_exp = read.table('../PGS000778_Tadros_Nat_Genet_HCM_hg38.txt_harmonized_prs_ccss_exp.all_score', header = TRUE)
HCM_tadros_exp = HCM_tadros_exp[c('IID', 'Pt_1')]
HCM_tadros_org = read.table('../PGS000778_Tadros_Nat_Genet_HCM_hg19.txt_harmonized_prs_ccss_org.all_score', header = TRUE)
HCM_tadros_org = HCM_tadros_org %>% separate(IID, c('FID', 'IID'), sep = "_")
HCM_tadros_org = HCM_tadros_org[c('IID', 'Pt_1')]
HCM_tadros = rbind(HCM_tadros_exp, HCM_tadros_org)
colnames(HCM_tadros)[2] = 'SCORE_HCM_tadros'
# LVEF
LVEF_pirruccello_exp = read.table('../Pirruccello_Nat_Comm_LVEF_hg38.txt_harmonized_prs_ccss_exp.all_score', header = TRUE)
LVEF_pirruccello_exp = LVEF_pirruccello_exp[c('IID', 'Pt_1')]
LVEF_pirruccello_org = read.table('../Pirruccello_Nat_Comm_LVEF_hg19.txt_harmonized_prs_ccss_org.all_score', header = TRUE)
LVEF_pirruccello_org = LVEF_pirruccello_org %>% separate(IID, c('FID', 'IID'), sep = "_")
LVEF_pirruccello_org = LVEF_pirruccello_org[c('IID', 'Pt_1')]
LVEF_pirruccello = rbind(LVEF_pirruccello_exp, LVEF_pirruccello_org)
colnames(LVEF_pirruccello)[2] = 'SCORE_LVEF_pirruccello'
# LVESVi
LVESVi_exp = read.table('../Pirruccello_Nat_Comm_LVESVi_hg38.txt_harmonized_revised_prs_ccss_exp_revised.all_score', header = TRUE)
LVESVi_exp = LVESVi_exp[c('IID', 'Pt_1')]
LVESVi_org = read.table('../Pirruccello_Nat_Comm_LVESVi_hg19.txt_harmonized_prs_ccss_org.all_score', header = TRUE)
LVESVi_org = LVESVi_org %>% separate(IID, c('FID', 'IID'), sep = "_")
LVESVi_org = LVESVi_org[c('IID', 'Pt_1')]
LVESVi = rbind(LVESVi_exp, LVESVi_org)
colnames(LVESVi)[2] = 'SCORE_LVESVi'
# ACT
ACT_exp = read.table('../Cardiomyopathy_survivors_studies_hg38.txt_harmonized_prs_ccss_exp.all_score', header = TRUE)
ACT_exp = ACT_exp[c('IID', 'Pt_1')]
ACT_org = read.table('../Cardiomyopathy_survivors_studies_hg19.txt_harmonized_prs_ccss_org.all_score', header = TRUE)
ACT_org = ACT_org %>% separate(IID, c('FID', 'IID'), sep = "_")
ACT_org = ACT_org[c('IID', 'Pt_1')]
ACT = rbind(ACT_exp, ACT_org)
colnames(ACT)[2] = 'SCORE_ACT'
# HF
HF_exp = read.table('../PGS001790_Wang_medRxiv_HF_hg38.txt_harmonized_prs_ccss_exp.all_score', header = TRUE)
HF_exp = HF_exp[c('IID', 'Pt_1')]
colnames(HF_exp)[2] = 'SCORE_HF'
HF_org = read.table('../PGS001790_Wang_medRxiv_HF_hg19.txt_harmonized_prs_ccss_org.all_score', header = TRUE)
HF_org = HF_org %>% separate(IID, c('FID', 'IID'), sep = "_")
HF_org = HF_org[c('IID', 'Pt_1')]
colnames(HF_org)[2] = 'SCORE_HF'
HF = rbind(HF_exp, HF_org)

prs_list = list(DCM_tadros, HCM_tadros, LVEF_pirruccello, LVESVi, ACT, HF)
all_prs.ccss = Reduce(function(x, y) merge(x, y, all=TRUE), prs_list)
# Merge ancestry and PRS
dat.ccss = merge(ccss_ancestry, all_prs.ccss, by.x = 'ccssid', by.y = 'IID')
save(dat.sjlife, dat.ccss, file = 'genetic_data_sjlife_ccss_for_cardiomyopathy_prediction_Yan_revised.RData')
