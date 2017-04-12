# sunitinib_merge.R 
# 4/12/2017
# Before running this script the load_core_citation_data.R script
# shoud be run after editing it to ensure that a drug_rev.R file is generated
# in the appropriate drug_assembly folder

setwd("~/NETELabs_CaseStudies/assembly/ramucirumab_assembly/")
system("git pull")
rm(list=ls())

suni_ct <- read.csv("sunitinib_ct.csv",stringsAsFactors=FALSE)
suni_nct <- read.csv("sunitinib_nct.csv",stringsAsFactors=FALSE)
suni_fda <- read.csv("sunitinib_fda.csv",stringsAsFactors=FALSE)
suni_patent <- read.csv("sunitinib_patent.csv",stringsAsFactors=FALSE)
suni_pmid1 <- read.csv("sunitinib_pmid1.csv",stringsAsFactors=FALSE)

library(dplyr)
# clinical trials component
suni_ct1 <- suni_ct %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
suni_ct2 <- suni_ct %>% mutate(source="sunitinib",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
suni_ct3 <- suni_nct %>% mutate(source="sunitinib",stype="root",
target=nct_id,ttype="ct") %>% select(source,stype,target,ttype)

# fda component
suni_fda1 <- suni_fda %>% mutate(source="bla_125477",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
suni_fda2 <- c("sunitinib","root","bla_125477","fda")

# patent component
suni_patent1 <- suni_patent %>% mutate(source="us7498414",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
suni_patent2 <- c("sunitinib","root","us7498414","patent")

# pmid1 component
suni_pmid1_1 <- suni_pmid1 %>% mutate(source="sunitinib",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from 
# ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R
suni_pmid1_2 <- read.csv("suni_rev.csv",stringsAsFactors=FALSE)

suni_merge1 <-rbind(suni_ct1,suni_ct2,suni_ct3,suni_patent1,suni_patent2,suni_fda1,suni_fda2,
suni_pmid1_1,suni_pmid1_2)
suni_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(suni_merge1,file="suni_merge1.csv")

suni_eric1 <- suni_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()

ae1 <- suni_eric1[1:400,]
ae1 <- as.integer(ae1)
ae2 <- suni_eric1[401:800,]
ae2 <- as.integer(ae2)
ae3 <- suni_eric1[801:1200,]
ae3 <- as.integer(ae3)
ae4 <- suni_eric1[1201:1600,]
ae4 <- as.integer(ae4)
ae5 <- suni_eric1[1601:length(suni_eric1$target),]
ae5 <- as.integer(ae5)

library(rentrez)
ae1_1 <- entrez_summary(db="pubmed",id=ae1)
print("ae1 rentrez_summaried")
Sys.sleep(120)
ae2_1 <- entrez_summary(db="pubmed",id=ae2)
print("ae2 rentrez_summaried")
Sys.sleep(120)
ae3_1 <- entrez_summary(db="pubmed",id=ae3)
print("ae3 rentrez_summaried")
Sys.sleep(120)
ae4_1 <- entrez_summary(db="pubmed",id=ae4)
print("ae4 rentrez_summaried")
Sys.sleep(120)
ae5_1 <- entrez_summary(db="pubmed",id=ae5)

source ("~/NETELabs_CaseStudies/assembly/ericformat.R")
ae1_2 <- ericFormat(ae1_1)
ae2_2 <- ericFormat(ae2_1)
ae3_2 <- ericFormat(ae3_1)
ae4_2 <- ericFormat(ae4_1)
ae5_2 <- ericFormat(ae5_1)

suni_eric_stage1 <- rbind(ae1_2,ae2_2,ae3_2,ae4_2,ae5_2)
write.csv(suni_eric_stage1,file="suni_eric_stage1.csv")














