# imatinib_merge.R 
# 4/12/2017
# Before running this script the load_core_citation_data.R script
# shoud be run after editing it to ensure that a drug_rev.R file is generated
# in the appropriate drug_assembly folder

setwd("~/NETELabs_CaseStudies/assembly/nelarabine_assembly/")
system("git pull")
rm(list=ls())

# check that the header for these four csv files has "pmid" as first line
nela_ct <- read.csv("nelarabine_ct.csv",stringsAsFactors=FALSE)
nela_nct <- read.csv("nelarabine_nct.csv",stringsAsFactors=FALSE)
nela_fda <- read.csv("nelarabine_fda.csv",stringsAsFactors=FALSE)
nela_patents <- read.csv("nelarabine_patent.csv",stringsAsFactors=FALSE)
nela_pmid1 <- read.csv("nelarabine_pmid1.csv",stringsAsFactors=FALSE)

library(dplyr)

# clinical trials component
nela_ct1 <- nela_ct %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
nela_ct2 <- nela_ct %>% mutate(source="nelarabine",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)


nela_fda1 <- nela_fda %>% mutate(source="nda_21335",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
nela_fda2 <- c("nelarabine","root","nda_21335","fda")

# no patent citations in Gleevec document but run this section anyway
nela_patent1 <- nela_patents %>% mutate(source="us5521184",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
nela_patent2 <- c("nelarabine","root","us5521184","patent")

nela_pmid1_1 <- nela_pmid1 %>% mutate(source="nelarabine",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from 
# ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R
nela_pmid1_2 <- read.csv("nela_rev.csv",stringsAsFactors=FALSE)

nela_merge1 <-rbind(nela_ct1,nela_ct2,nela_patent1,nela_patent2,nela_fda1,nela_fda2,
nela_pmid1_1,nela_pmid1_2)
nela_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(nela_merge1,file="nela_merge1.csv")

nela_eric1 <- nela_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()

ae1 <- nela_eric1[1:400,]
ae1 <- as.integer(ae1)
ae2 <- nela_eric1[401:800,]
ae2 <- as.integer(ae2)
ae3 <- nela_eric1[801:1200,]
ae3 <- as.integer(ae3)
ae4 <- nela_eric1[1201:length(nela_eric1$target),]
ae4 <- as.integer(ae4)

library(rentrez)
ae1_1 <- entrez_summary(db="pubmed",id=ae1)
print("ae1 rentrez_summaried")
Sys.sleep(60)
ae2_1 <- entrez_summary(db="pubmed",id=ae2)
print("ae2 rentrez_summaried")
Sys.sleep(60)
ae3_1 <- entrez_summary(db="pubmed",id=ae3)
print("ae3 rentrez_summaried")
Sys.sleep(60)
ae4_1 <- entrez_summary(db="pubmed",id=ae4)
print("ae4 rentrez_summaried")
Sys.sleep(60)

source ("~/NETELabs_CaseStudies/assembly/ericformat.R")
ae1_2 <- ericFormat(ae1_1)
ae2_2 <- ericFormat(ae2_1)
ae3_2 <- ericFormat(ae3_1)
ae4_2 <- ericFormat(ae4_1)

nela_eric_stage1 <- rbind(ae1_2,ae2_2,ae3_2,ae4_2)
write.csv(nela_eric_stage1,file="nela_eric_stage1.csv")














