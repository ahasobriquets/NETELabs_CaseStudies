# processes a list of pmids from ramucirumab_master into a pmid1 list
# for Eric Livingston to get cited pmids from 
library(rentrez)
library(dplyr)
ramucirumab_master <- read.csv("~/NETELabs_CaseStudies/ramucirumabramucirumab_master.csv",
stringsAsFactors=FALSE)
ramucirumab_master <- ramucirumab_master[complete.cases(ramucirumab_master),]
ramucirumab_pmid1 <- ramucirumab_master %>% filter(ttype=="pmid1") %>% select (target) %>% unique()
ramucirumab_entrez <- entrez_summary(db="pubmed",id=ramucirumab_master$target)
ramucirumab_entrez <- entrez_summary(db="pubmed",id=ramucirumab_master$target)
ramucirumab_eric <- clean_entrez2(ramucirumab_entrez)
write.csv(ramucirumab_eric,file="~/NETELabs_CaseStudies/ramucirumab/ramucirumab_eric.csv")
