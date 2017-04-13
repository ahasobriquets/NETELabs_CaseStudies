# imatinib_merge.R 
# 4/13/2017
# George Chacko

# Metadata file 
# imatinib_metadata

# List of input files.
# imatinib_fda_review.csv (single column, header is pmid)
# imatinib_fda_pazdur.csv (single column, header is pmid)
# imatinib_patent_npl.csv (single column, header is pmid)
# imatinib_ct_nct.csv (two column, header is nct_id, pmid)
# imatinib_ct_pubmed.csv (single column, header is pmid)
# imatinib_pubmed.csv (single column, header is pmid)
# imat_rev.csv (product of ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R)

# ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R
source("/Users/George/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R")

setwd("~/NETELabs_CaseStudies/assembly/imatinib_assembly/")
system("git pull")
rm(list=ls())
library(dplyr)

## Clinical Trials Component
#  Root to pubmed_derived clinical trials 
imat_ct_pubmed <- read.csv("imatinib_ct_pubmed.csv",stringsAsFactors=FALSE)
imat_ct1 <- imat_ct_pubmed %>% mutate(source="imatinib",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# pmid_ct to pmid1
imat_ct2 <- imat_ct_pubmed %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

# Root to nct_derived clinical trials
imat_ct_nct <- read.csv("imatinib_ct_nct.csv",stringsAsFactors=FALSE)

imat_ct3 <- imat_ct_nct %>% mutate(source="imatinib",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# nct to pmid1
imat_ct4 <- imat_ct_nct %>% mutate(source=nct_id,stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

## FDA Component
# Scraped Medical Review derived
imat_fda_review <- read.csv("imatinib_fda_review.csv",stringsAsFactors=FALSE)
imat_fda1 <- imat_fda_review %>% mutate(source="bla_103948",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
# FDA Approval Summary derived (Pazdur)
imat_fda_pazdur <- read.csv("imatinib_fda_pazdur.csv",stringsAsFactors=FALSE)
imat_fda2 <- imat_fda_pazdur %>% mutate(source="nda_21335",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype)
imat_fda3 <- c("imatinib","root","nda_21335","fda")

## Patent Component
imat_patent <- read.csv("imatinib_patent.csv",stringsAsFactors=FALSE)
imat_patent1 <- imat_patent %>% mutate(source="us5521184",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
imat_patent2 <- c("imatinib","root","us5521184","patent")

## Pubmed Component
imat_pmid1 <- read.csv("imatinib_pubmed.csv",stringsAsFactors=FALSE)
imat_pmid1_1 <- imat_pmid1 %>% mutate(source="imatinib",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from load_core_citation_data script run at beginnning
imat_pmid1_2 <- read.csv("imat_rev.csv",stringsAsFactors=FALSE)

## Merge all components
imat_merge1 <-rbind(imat_ct1,imat_ct2,imat_ct3,imat_ct4,
imat_fda1,imat_fda2,imat_fda3,
imat_patent1,imat_patent2,
imat_pmid1_1,imat_pmid1_2)
imat_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(imat_merge1,file="imat_merge1.csv")

## Generate a list of unique pmids for Eric
imat_eric1 <- imat_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()
print(dim(imat_eric1))

## Format list per Eric's specs using rentrez in chunks
ae1 <- imat_eric1[1:400,]
ae1 <- as.integer(ae1)
ae2 <- imat_eric1[401:800,]
ae2 <- as.integer(ae2)
ae3 <- imat_eric1[801:1200,]
ae3 <- as.integer(ae3)
ae4 <- imat_eric1[1201:length(imat_eric1$target),]
ae4 <- as.integer(ae4)

library(rentrez)
ae1_1 <- entrez_summary(db="pubmed",id=ae1)
Sys.sleep(120)
ae2_1 <- entrez_summary(db="pubmed",id=ae2)
Sys.sleep(120)
ae3_1 <- entrez_summary(db="pubmed",id=ae3)
Sys.sleep(120)
ae4_1 <- entrez_summary(db="pubmed",id=ae4)

# Call Custom Function to build data frame from list
source ("~/NETELabs_CaseStudies/assembly/ericformat.R")
ae1_2 <- ericFormat(ae1_1)
ae2_2 <- ericFormat(ae2_1)
ae3_2 <- ericFormat(ae3_1)
ae4_2 <- ericFormat(ae4_1)

# Write out final output for eric
imat_eric_stage1 <- rbind(ae1_2,ae2_2,ae3_2,ae4_2)
imat_eric_stage1 <- imat_eric_stage1 %>% mutate(drug_name="imatinib")
write.csv(imat_eric_stage1,file="imat_eric_stage1.csv")














