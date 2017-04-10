# imatinib_merge.R 
# 4/7/2017

setwd("~/NETELabs_CaseStudies/assembly/imatinib_assembly/")
system("git pull")
rm(list=ls())

imat_ct <- read.csv("imatinib_ct.csv",stringsAsFactors=FALSE)
imat_fda <- read.csv("imatinib_fda.csv",stringsAsFactors=FALSE)
imat_patents <- read.csv("imatinib_patent.csv",stringsAsFactors=FALSE)
imat_pmid1 <- read.csv("imatinib_pmid1.csv",stringsAsFactors=FALSE)

library(dplyr)

imat_ct1 <- imat_ct %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
imat_ct2 <- imat_ct %>% mutate(source="imatinib",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)

imat_fda1 <- imat_fda %>% mutate(source="bla_103948",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
imat_fda2 <- c("imatinib","root","bla_103948","fda")

imat_patent1 <- imat_patents %>% mutate(source="us5846534",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
imat_patent2 <- c("imatinib","root","us5846534","patent")

imat_pmid1_1 <- imat_pmid1 %>% mutate(source="imatinib",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from 
# ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R
imat_pmid1_2 <- read.csv("imat_rev.csv",stringsAsFactors=FALSE)

imat_merge1 <-rbind(imat_ct1,imat_ct2,imat_patent1,imat_patent2,imat_fda1,imat_fda2,
imat_pmid1_1,imat_pmid1_2)
imat_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(imat_merge1,file="imat_merge1.csv")

imat_eric1 <- imat_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()

ae1 <- imat_eric1[1:400,]
ae1 <- as.integer(ae1)
ae2 <- imat_eric1[401:length(imat_eric1$target),]
ae2 <- as.integer(ae2)

library(rentrez)
ae1_1 <- entrez_summary(db="pubmed",id=ae1)
Sys.sleep(30)
ae2_1 <- entrez_summary(db="pubmed",id=ae2)
source ("~/NETELabs_CaseStudies/assembly/ericformat.R")

ae1_2 <- ericFormat(ae1_1)
ae2_2 <- ericFormat(ae2_1)

imat_eric_stage1 <- rbind(ae1_2,ae2_2)
write.csv(imat_eric_stage1,file="imat_eric_stage1.csv")














