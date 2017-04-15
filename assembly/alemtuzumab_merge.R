# alemtuzumab_merge.R 
# 4/13/2017
# George Chacko

# Metadata file 
# alemtuzumab_metadata

# List of input files.
# alemtuzumab_fda_review.csv (single column, header is pmid)
# alemtuzumab_fda_pazdur.csv (single column, header is pmid)
# alemtuzumab_patent_npl.csv (single column, header is pmid)
# alemtuzumab_ct_nct.csv (two column, header is nct_id, pmid)
# alemtuzumab_ct_pubmed.csv (single column, header is pmid)
# alemtuzumab_pubmed.csv (single column, header is pmid)
# alem_rev.csv (product of ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R)

# ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R
# This script generates a set of citations from reviews of the drug/biological in question 
source("/Users/George/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R")

setwd("~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/")
system("git pull")
rm(list=ls())
library(dplyr)

## Clinical Trials Component
#  Root to pubmed_derived clinical trials 
alem_ct_pubmed <- read.csv("alemtuzumab_ct_pubmed.csv",stringsAsFactors=FALSE)
alem_ct1 <- alem_ct_pubmed %>% mutate(source="alemtuzumab",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# pmid_ct to pmid1
alem_ct2 <- alem_ct_pubmed %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

# Root to nct_derived clinical trials
alem_ct_nct <- read.csv("alemtuzumab_ct_nct.csv",stringsAsFactors=FALSE)

alem_ct3 <- alem_ct_nct %>% mutate(source="alemtuzumab",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# nct to pmid1
alem_ct4 <- alem_ct_nct %>% mutate(source=nct_id,stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

## FDA Component
# Scraped Medical Review derived
alem_fda_review <- read.csv("alemtuzumab_fda_review.csv",stringsAsFactors=FALSE)
alem_fda1 <- alem_fda_review %>% mutate(source="bla_103948",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
# FDA Approval Summary derived (Pazdur)
alem_fda_pazdur <- read.csv("alemtuzumab_fda_pazdur.csv",stringsAsFactors=FALSE)
alem_fda2 <- alem_fda_pazdur %>% mutate(source="bla_103948",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype)
alem_fda3 <- c("alemtuzumab","root","bla_103948","fda")

## Patent Component
alem_patent <- read.csv("alemtuzumab_patent_npl.csv",stringsAsFactors=FALSE)
alem_patent1 <- alem_patent %>% mutate(source="us5846534",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
alem_patent2 <- c("alemtuzumab","root","us5846534","patent")

## Pubmed Component
alem_pmid1 <- read.csv("alemtuzumab_pubmed.csv",stringsAsFactors=FALSE)
alem_pmid1_1 <- alem_pmid1 %>% mutate(source="alemtuzumab",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from load_core_citation_data script run at beginnning
alem_pmid1_2 <- read.csv("alem_rev.csv",stringsAsFactors=FALSE)

## Merge all components
alem_merge1 <-rbind(alem_ct1,alem_ct2,alem_ct3,alem_ct4,
alem_fda1,alem_fda2,alem_fda3,
alem_patent1,alem_patent2,
alem_pmid1_1,alem_pmid1_2)
alem_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(alem_merge1,file="alem_merge1.csv")

## Generate a list of unique pmids for Eric
alem_eric1 <- alem_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()
print(dim(alem_eric1))

## Format list per Eric's specs using rentrez in chunks
ae1 <- alem_eric1[1:400,]
ae1 <- as.integer(ae1)
ae2 <- alem_eric1[401:length(alem_eric1$target),]
ae2 <- as.integer(ae2)

library(rentrez)
ae1_1 <- entrez_summary(db="pubmed",id=ae1)
Sys.sleep(30)
ae2_1 <- entrez_summary(db="pubmed",id=ae2)

# Call Custom Function to build data frame from list
source ("~/NETELabs_CaseStudies/assembly/ericformat.R")
ae1_2 <- ericFormat(ae1_1)
ae2_2 <- ericFormat(ae2_1)

# Write out final output for eric
alem_eric_stage1 <- rbind(ae1_2,ae2_2)
alem_eric_stage1 <- na.omit(alem_eric_stage1)
alem_eric_stage1 <- alem_eric_stage1 %>% mutate(drug_name="alemtuzumab")
write.csv(alem_eric_stage1,file="alem_eric_stage1.csv")














