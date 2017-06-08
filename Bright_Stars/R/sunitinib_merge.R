 # sunitinib_merge.R 
# 4/14/2017
# George Chacko

# Metadata file 
# sunitinib_metadata

# List of input files.
# sunitinib_fda_review.csv (single column, header is pmid)
# sunitinib_fda_pazdur.csv (single column, header is pmid)
# sunitinib_patent_npl.csv (single column, header is pmid)
# sunitinib_ct_nct.csv (two column, header is nct_id, pmid)
# sunitinib_ct_pubmed.csv (single column, header is pmid)
# sunitinib_pubmed.csv (single column, header is pmid)
# suni_rev.csv (product of ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R)

setwd("~/NETELabs_CaseStudies/assembly/sunitinib_assembly/")
system("git pull")
rm(list=ls())
library(dplyr)

## Clinical Trials Component
#  Root to pubmed_derived clinical trials 
suni_ct_pubmed <- read.csv("sunitinib_ct_pubmed.csv",stringsAsFactors=FALSE)
suni_ct1 <- suni_ct_pubmed %>% mutate(source="sunitinib",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# pmid_ct to pmid1
suni_ct2 <- suni_ct_pubmed %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

# Root to nct_derived clinical trials
suni_ct_nct <- read.csv("sunitinib_ct_nct.csv",stringsAsFactors=FALSE)

suni_ct3 <- suni_ct_nct %>% mutate(source="sunitinib",stype="root",
target=nct_id,ttype="ct") %>% select(source,stype,target,ttype)
# nct to pmid1
suni_ct4 <- suni_ct_nct %>% mutate(source=nct_id,stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

## FDA Component
# Scraped Medical Review derived
suni_fda_review <- read.csv("sunitinib_fda_review.csv",stringsAsFactors=FALSE)
suni_fda1 <- suni_fda_review %>% mutate(source="nda_21938",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
# FDA Approval Summary derived (Pazdur)
suni_fda_pazdur <- read.csv("sunitinib_fda_pazdur.csv",stringsAsFactors=FALSE)
suni_fda2 <- suni_fda_pazdur %>% mutate(source="nda_21938",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype)
suni_fda3 <- c("sunitinib","root","nda_21938","fda")

## Patent Component
suni_patent <- read.csv("sunitinib_patent_npl.csv",stringsAsFactors=FALSE)
suni_patent1 <- suni_patent %>% mutate(source="us6573293",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
suni_patent2 <- c("sunitinib","root","us6573293","patent")

## Pubmed Component
suni_pmid1 <- read.csv("sunitinib_pubmed.csv",stringsAsFactors=FALSE)
suni_pmid1_1 <- suni_pmid1 %>% mutate(source="sunitinib",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from load_core_citation_data script run at beginnning
suni_pmid1_2 <- read.csv("suni_rev.csv",stringsAsFactors=FALSE)

## Merge all components
suni_merge1 <-rbind(suni_ct1,suni_ct2,suni_ct3,suni_ct4,
suni_fda1,suni_fda2,suni_fda3,
suni_patent1,suni_patent2,
suni_pmid1_1,suni_pmid1_2)
suni_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(suni_merge1,file="suni_merge1.csv")

## Generate a list of unique pmids for Eric
suni_eric1 <- suni_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()
suni_eric1 <- na.omit(suni_eric1)
print(dim(suni_eric1))

## Format list per Eric's specs using rentrez in chunks
ae1 <- suni_eric1[1:400,]
ae1 <- as.integer(ae1)
ae2 <- suni_eric1[401:800,]
ae2 <- as.integer(ae2)
ae3 <- suni_eric1[801:1200,]
ae3 <- as.integer(ae3)
ae4 <- suni_eric1[1201:length(suni_eric1$target),]
ae4 <- as.integer(ae4)

library(rentrez)
ae1_1 <- entrez_summary(db="pubmed",id=ae1)
Sys.sleep(120)
ae2_1 <- entrez_summary(db="pubmed",id=ae2)
Sys.sleep(120)
ae3_1 <- entrez_summary(db="pubmed",id=ae3)
Sys.sleep(120)
ae4_1 <- entrez_summary(db="pubmed",id=ae4)
Sys.sleep(120)

# Call Custom Function to build data frame from list
source ("~/NETELabs_CaseStudies/assembly/ericformat.R")
ae1_2 <- ericFormat(ae1_1)
ae2_2 <- ericFormat(ae2_1)
ae3_2 <- ericFormat(ae3_1)
ae4_2 <- ericFormat(ae4_1)

# Write out final output for eric
suni_eric_stage1 <- rbind(ae1_2,ae2_2,ae3_2,ae4_2)
suni_eric_stage1 <- suni_eric_stage1 %>% mutate(drug_name="sunitinib")
write.csv(suni_eric_stage1,file="suni_eric_stage1.csv")














