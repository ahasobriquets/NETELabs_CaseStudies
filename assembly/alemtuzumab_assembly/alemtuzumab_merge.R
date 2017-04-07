# alemtuzumab_merge.R 
# 4/7/2017

setwd("~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/")
system("git pull")
rm(list=ls())

alem_ct <- read.csv("alemtuzumab_ct_csv",stringsAsFactors=FALSE)
alem_fda <- read.csv("alemtuzumab_fda.csv",stringsAsFactors=FALSE)
alem_patents <- read.csv("alemtuzumab_patent.csv",stringsAsFactors=FALSE)
alem_pmid1 <- read.csv("alemtuzumab_fda.csv",stringsAsFactors=FALSE)

library(dplyr)
