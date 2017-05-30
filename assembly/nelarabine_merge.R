# nelarabine_merge.R 
# 4/13/2017
# George Chacko

# Metadata file 
# nelarabine_metadata

# List of input files.
# nelarabine_fda_review.csv (single column, header is pmid)
# nelarabine_fda_pazdur.csv (single column, header is pmid)
# nelarabine_patent_npl.csv (single column, header is pmid)
# nelarabine_ct_nct.csv (two column, header is nct_id, pmid)
# nelarabine_ct_pubmed.csv (single column, header is pmid)
# nelarabine_pubmed.csv (single column, header is pmid)
# nela_rev.csv (product of ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R)

setwd("~/NETELabs_CaseStudies/assembly/nelarabine_assembly/")
system("git pull")
rm(list=ls())
library(dplyr)

## Clinical Trials Component
#  Root to pubmed_derived clinical trials 
nela_ct_pubmed <- read.csv("nelarabine_ct_pubmed.csv",stringsAsFactors=FALSE)
nela_ct1 <- nela_ct_pubmed %>% mutate(source="nelarabine",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# pmid_ct to pmid1
nela_ct2 <- nela_ct_pubmed %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

# Root to nct_derived clinical trials
nela_ct_nct <- read.csv("nelarabine_ct_nct.csv",stringsAsFactors=FALSE)

nela_ct3 <- nela_ct_nct %>% mutate(source="nelarabine",stype="root",
target=nct_id,ttype="ct") %>% select(source,stype,target,ttype)
# nct to pmid1
nela_ct4 <- nela_ct_nct %>% mutate(source=nct_id,stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

## FDA Component
# Scraped Medical Review derived
nela_fda_review <- read.csv("nelarabine_fda_review.csv",stringsAsFactors=FALSE)
nela_fda1 <- nela_fda_review %>% mutate(source="nda_21877",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
# FDA Approval Summary derived (Pazdur)
nela_fda_pazdur <- read.csv("nelarabine_fda_pazdur.csv",stringsAsFactors=FALSE)
nela_fda2 <- nela_fda_pazdur %>% mutate(source="nda_21877",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype)
nela_fda3 <- c("nelarabine","root","nda_21877","fda")

## Patent Component
nela_patent <- read.csv("nelarabine_patent_npl.csv",stringsAsFactors=FALSE)
nela_patent1 <- nela_patent %>% mutate(source="us5424295",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
nela_patent2 <- c("nelarabine","root","us5424295","patent")

## Pubmed Component
nela_pmid1 <- read.csv("nelarabine_pubmed.csv",stringsAsFactors=FALSE)
nela_pmid1_1 <- nela_pmid1 %>% mutate(source="nelarabine",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from load_core_citation_data script run at beginnning
nela_pmid1_2 <- read.csv("nela_rev.csv",stringsAsFactors=FALSE)

## Merge all components
nela_merge1 <-rbind(nela_ct1,nela_ct2,nela_ct3,nela_ct4,
nela_fda1,nela_fda2,nela_fda3,
nela_patent1,nela_patent2,
nela_pmid1_1,nela_pmid1_2)
nela_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(nela_merge1,file="nela_merge1.csv")

## Generate a list of unique pmids for Eric
nela_eric1 <- nela_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()
nela_eric1 <- na.omit(nela_eric1)
print(dim(nela_eric1))

## Format list per Eric's specs using rentrez in chunks
ae1 <- nela_eric1[1:length(nela_eric1$target),]
ae1 <- as.integer(ae1)
library(rentrez)
ae1_1 <- entrez_summary(db="pubmed",id=ae1)
# Sys.sleep(120)

# Call Custom Function to build data frame from list
source ("~/NETELabs_CaseStudies/assembly/ericformat.R")
ae1_2 <- ericFormat(ae1_1)

# Write out final output for eric
nela_eric_stage1 <- ae1_2
nela_eric_stage1 <- nela_eric_stage1 %>% mutate(drug_name="nelarabine")
write.csv(nela_eric_stage1,file="nela_eric_stage1.csv")














