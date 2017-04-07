# alemtuzumab_merge.R 
# 4/7/2017

setwd("~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/")
system("git pull")
rm(list=ls())

alem_ct <- read.csv("alemtuzumab_ct_csv",stringsAsFactors=FALSE)
alem_fda <- read.csv("alemtuzumab_fda.csv",stringsAsFactors=FALSE)
alem_patents <- read.csv("alemtuzumab_patent.csv",stringsAsFactors=FALSE)
alem_pmid1 <- read.csv("alemtuzumab_pmid1.csv",stringsAsFactors=FALSE)

library(dplyr)

alem_ct1 <- alem_ct %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
alem_ct2 <- alem_ct %>% mutate(source="alemtuzumab",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)

alem_fda1 <- alem_fda %>% mutate(source="bla_103948",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
alem_fda2 <- c("alemtuzumab","root","bla_103948","fda")

alem_patent1 <- alem_patents %>% mutate(source="us5846534",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
alem_patent2 <- c("alemtuzumab","root","us5846534","patent")

alem_pmid1_1 <- alem_pmid1 %>% mutate(source="alemtuzumab",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from 
# ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R
alem_pmid1_2 <- read.csv("alem_rev.csv",stringsAsFactors=FALSE)

alem_merge1 <-rbind(alem_ct1,alem_ct2,alem_patent1,alem_patent2,alem_fda1,alem_fda2,
alem_pmid1_1,alem_pmid1_2)
alem_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(alem_merge1,file="alem_merge1.csv")

alem_eric1 <- alem_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()

ae1 <- alem_eric1[1:400,]
ae1 <- as.integer(ae1)
ae2 <- alem_eric1[401:length(alem_eric1$target),]
ae2 <- as.integer(ae2)

library(rentrez)
ae1_1 <- entrez_summary(db="pubmed",id=ae1)
Sys.sleep(30)
ae2_1 <- entrez_summary(db="pubmed",id=ae2)
source ("~/NETELabs_CaseStudies/assembly/ericformat.R")

ae1_2 <- ericFormat(ae1_1)
ae2_2 <- ericFormat(ae2_1)

alem_eric_stage1 <- rbind(ae1_2,ae2_2)
write.csv(alem_eric_stage1,file="alem_eric_stage1.csv")














