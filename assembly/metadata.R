# Metadata Script for five_pack
library(dplyr)
setwd("~/NETELabs_CaseStudies/assembly")
rm(list=ls())
alem <- read.csv("alemtuzumab_assembly/alem_merge1.csv",stringsAsFactors=FALSE)
alem_metadata <- alem %>% group_by(stype,ttype) %>% summarize(counts=length(target)) %>% 
arrange(desc(stype)) %>% mutate(drug="alemtuzumab") %>% select(drug,stype,ttype,counts)

setwd("~/NETELabs_CaseStudies/assembly")
imat <- read.csv("imatinib_assembly/imat_merge1.csv",stringsAsFactors=FALSE)
imat_metadata <- imat %>% group_by(stype,ttype) %>% summarize(counts=length(target)) %>% 
arrange(desc(stype)) %>% mutate(drug="imatinib") %>% select(drug,stype,ttype,counts)

setwd("~/NETELabs_CaseStudies/assembly")
nela <- read.csv("nelarabine_assembly/nela_merge1.csv",stringsAsFactors=FALSE)
nela_metadata <- nela %>% group_by(stype,ttype) %>% summarize(counts=length(target)) %>% 
arrange(desc(stype)) %>% mutate(drug="nelarabine") %>% select(drug,stype,ttype,counts) 

setwd("~/NETELabs_CaseStudies/assembly")
ramu <- read.csv("ramucirumab_assembly/ramu_merge1.csv",stringsAsFactors=FALSE)
ramu_metadata <- ramu %>% group_by(stype,ttype) %>% summarize(counts=length(target)) %>% 
arrange(desc(stype)) %>% mutate(drug="ramucirumab") %>% select(drug,stype,ttype,counts)

setwd("~/NETELabs_CaseStudies/assembly")
suni <- read.csv("sunitinib_assembly/suni_merge1.csv",stringsAsFactors=FALSE)
suni_metadata <- suni %>% group_by(stype,ttype) %>% summarize(counts=length(target)) %>% 
arrange(desc(stype)) %>% mutate(drug="sunitinib") %>% select(drug,stype,ttype,counts)

fp_metadata <- rbind(alem_metadata,imat_metadata,nela_metadata,ramu_metadata,suni_metadata) %>% data.frame()


