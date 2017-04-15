# ramucirumab_merge.R 
# 4/13/2017
# George Chacko

# Metadata file 
# ramucirumab_metadata

# List of input files.
# ramucirumab_fda_review.csv (single column, header is pmid)
# ramucirumab_fda_pazdur.csv (single column, header is pmid)
# ramucirumab_patent_npl.csv (single column, header is pmid)
# ramucirumab_ct_nct.csv (two column, header is nct_id, pmid)
# ramucirumab_ct_pubmed.csv (single column, header is pmid)
# ramucirumab_pubmed.csv (single column, header is pmid)
# ramu_rev.csv (product of ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R)

# ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R
source("/Users/George/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R")

setwd("~/NETELabs_CaseStudies/assembly/ramucirumab_assembly/")
system("git pull")
rm(list=ls())
library(dplyr)

## Clinical Trials Component
#  Root to pubmed_derived clinical trials 
ramu_ct_pubmed <- read.csv("ramucirumab_ct_pubmed.csv",stringsAsFactors=FALSE)
ramu_ct1 <- ramu_ct_pubmed %>% mutate(source="ramucirumab",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# pmid_ct to pmid1
ramu_ct2 <- ramu_ct_pubmed %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

# Root to nct_derived clinical trials
ramu_ct_nct <- read.csv("ramucirumab_ct_nct.csv",stringsAsFactors=FALSE)

ramu_ct3 <- ramu_ct_nct %>% mutate(source="ramucirumab",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# nct to pmid1
ramu_ct4 <- ramu_ct_nct %>% mutate(source=nct_id,stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

## FDA Component
# Scraped Medical Review derived
ramu_fda_review <- read.csv("ramucirumab_fda_review.csv",stringsAsFactors=FALSE)
ramu_fda1 <- ramu_fda_review %>% mutate(source="bla_103948",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
# FDA Approval Summary derived (Pazdur)
ramu_fda_pazdur <- read.csv("ramucirumab_fda_pazdur.csv",stringsAsFactors=FALSE)
ramu_fda2 <- ramu_fda_pazdur %>% mutate(source="nda_21335",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype)
ramu_fda3 <- c("ramucirumab","root","nda_21335","fda")

## Patent Component
ramu_patent <- read.csv("ramucirumab_patent_npl.csv",stringsAsFactors=FALSE)
ramu_patent1 <- ramu_patent %>% mutate(source="us5521184",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
ramu_patent2 <- c("ramucirumab","root","us5521184","patent")

## Pubmed Component
ramu_pmid1 <- read.csv("ramucirumab_pubmed.csv",stringsAsFactors=FALSE)
ramu_pmid1_1 <- ramu_pmid1 %>% mutate(source="ramucirumab",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from load_core_citation_data script run at beginnning
ramu_pmid1_2 <- read.csv("ramu_rev.csv",stringsAsFactors=FALSE)

## Merge all components
ramu_merge1 <-rbind(ramu_ct1,ramu_ct2,ramu_ct3,ramu_ct4,
ramu_fda1,ramu_fda2,ramu_fda3,
ramu_patent1,ramu_patent2,
ramu_pmid1_1,ramu_pmid1_2)
ramu_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(ramu_merge1,file="ramu_merge1.csv")

## Generate a list of unique pmids for Eric
ramu_eric1 <- ramu_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()
ramu_eric1 <- na.omit(ramu_eric1)
print(dim(ramu_eric1))

## Format list per Eric's specs using rentrez in chunks
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
Sys.sleep(120)
ae2_1 <- entrez_summary(db="pubmed",id=ae2)
Sys.sleep(120)
ae3_1 <- entrez_summary(db="pubmed",id=ae3)
Sys.sleep(120)
ae4_1 <- entrez_summary(db="pubmed",id=ae4)
Sys.sleep(120)
ae5_1 <- entrez_summary(db="pubmed",id=ae5)

# Call Custom Function to build data frame from list
source ("~/NETELabs_CaseStudies/assembly/ericformat.R")
ae1_2 <- ericFormat(ae1_1)
ae2_2 <- ericFormat(ae2_1)
ae3_2 <- ericFormat(ae3_1)
ae4_2 <- ericFormat(ae4_1)
ae5_2 <- ericFormat(ae5_1)

# Write out final output for eric
ramu_eric_stage1 <- rbind(ae1_2,ae2_2,ae3_2,ae4_2,ae5_2)
ramu_eric_stage1 <- ramu_eric_stage1 %>% mutate(drug_name="ramucirumab")
write.csv(ramu_eric_stage1,file="ramu_eric_stage1.csv")














