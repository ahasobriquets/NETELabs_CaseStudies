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
alem_pmid1_2 <- read.csv("alem_rev.csv",stringsAsFactors=FALSE)

alem_merge1 <-rbind(alem_ct1,alem_ct2,alem_patent1,alem_patent2,alem_fda1,alem_fda2,
alem_pmid1_1,alem_pmid1_2)
alem_merge1 %>% arrange(desc(stype)) %>% unique()
alem_pmid1_for_eric <- alem_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()
write.csv(alem_merge1,file="alem_merge1.csv")
write.csv(alem_pmid1_for_eric,file="alem_pmid1_for_eric.csv")





