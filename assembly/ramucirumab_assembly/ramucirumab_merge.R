# imatinib_merge.R 
# 4/12/2017
# Before running this script the load_core_citation_data.R script
# shoud be run after editing it to ensure that a drug_rev.R file is generated
# in the appropriate drug_assembly folder

setwd("~/NETELabs_CaseStudies/assembly/ramucirumab_assembly/")
system("git pull")
rm(list=ls())

ramu_ct <- read.csv("ramucirumab_ct.csv",stringsAsFactors=FALSE)
ramu_nct <- read.csv("ramucirumab_nct.csv",stringsAsFactors=FALSE)
ramu_fda <- read.csv("ramucirumab_fda.csv",stringsAsFactors=FALSE)
ramu_patent <- read.csv("ramucirumab_patent.csv",stringsAsFactors=FALSE)
ramu_pmid1 <- read.csv("ramucirumab_pmid1.csv",stringsAsFactors=FALSE)

library(dplyr)
# clinical trials component
ramu_ct1 <- ramu_ct %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
ramu_ct2 <- ramu_ct %>% mutate(source="ramucirumab",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
ramu_ct3 <- ramu_nct %>% mutate(source="ramucirumab",stype="root",
target=nct_id,ttype="ct") %>% select(source,stype,target,ttype)

# fda component
ramu_fda1 <- ramu_fda %>% mutate(source="bla_125477",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
ramu_fda2 <- c("ramucirumab","root","bla_125477","fda")

# patent component
ramu_patent1 <- ramu_patent %>% mutate(source="us7498414",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
ramu_patent2 <- c("ramucirumab","root","us7498414","patent")

# pmid1 component
ramu_pmid1_1 <- ramu_pmid1 %>% mutate(source="ramucirumab",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from 
# ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R
ramu_pmid1_2 <- read.csv("ramu_rev.csv",stringsAsFactors=FALSE)

ramu_merge1 <-rbind(ramu_ct1,ramu_ct2,ramu_ct3,ramu_patent1,ramu_patent2,ramu_fda1,ramu_fda2,
ramu_pmid1_1,ramu_pmid1_2)
ramu_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(ramu_merge1,file="ramu_merge1.csv")

ramu_eric1 <- ramu_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()

ae1 <- ramu_eric1[1:400,]
ae1 <- as.integer(ae1)
ae2 <- ramu_eric1[401:800,]
ae2 <- as.integer(ae2)
ae3 <- ramu_eric1[801:1200,]
ae3 <- as.integer(ae3)
ae4 <- ramu_eric1[1201:1600,]
ae4 <- as.integer(ae4)
ae5 <- ramu_eric1[1601:length(ramu_eric1$target),]
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

ramu_eric_stage1 <- rbind(ae1_2,ae2_2,ae3_2,ae4_2,ae5_2)
write.csv(ramu_eric_stage1,file="ramu_eric_stage1.csv")














