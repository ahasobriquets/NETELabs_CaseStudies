# five_pack Stage I Assembly
setwd("~/Desktop")
rm(list=ls())
library(dplyr)
alem <- read.csv("~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/alem_eric_stage1.csv",stringsAsFactors=FALSE)
imat <- read.csv("~/NETELabs_CaseStudies/assembly/imatinib_assembly/imat_eric_stage1.csv",stringsAsFactors=FALSE)
nela <- read.csv("~/NETELabs_CaseStudies/assembly/nelarabine_assembly/nela_eric_stage1.csv",stringsAsFactors=FALSE)
ramu <- read.csv("~/NETELabs_CaseStudies/assembly/ramucirumab_assembly/ramu_eric_stage1.csv",stringsAsFactors=FALSE)
suni <- read.csv("~/NETELabs_CaseStudies/assembly/sunitinib_assembly/suni_eric_stage1.csv",stringsAsFactors=FALSE)
five_pack_stageI <- rbind(alem,imat,nela,ramu,suni)
five_pack_stageI <- five_pack_stageI[,-c(1,9)]
colnames(five_pack_stageI) <- c("pmid","pubdate","firstauthor","lastauthor","source","title","year")
five_pack_stageI[,"eid"] <- NA
five_pack_stageI <- five_pack_stageI %>% select (pmid, eid, pubdate,firstauthor,lastauthor,source,title,year)
library(dplyr)
five_pack_stageI %>% nrow()
five_pack_stageI %>% unique() %>% nrow()
five_pack_stageI <- five_pack_stageI %>% unique()

write.csv(five_pack_stageI,file="five_pack_stageI.csv",row.names=FALSE)
