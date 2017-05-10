# links pmids from pubref files to projects and study sections

rm(list=ls())
setwd("~/NETELabs_CaseStudies/assembly/final_results/")
# Load Exporter projects and pmid links
exporter_links <- read.csv("exporter_links.csv",stringsAsFactors=FALSE)
exporter_projects <- read.csv("exporter_projects.csv",stringsAsFactors=FALSE)
library(dplyr)
#working exporter projects df
wep <- exporter_projects %>% select (core_project_num,study_section,study_section_name)

#Alemtuzumab
alem_pubs <- read.csv("~/NETELabs_CaseStudies/assembly/interim_results/alem_pubref.csv",stringsAsFactors=FALSE)
alem_pmids <- union(alem_pubs$citing_pmid,alem_pubs$cited_pmid)
alem_pmids <- data.frame(alem_pmids)
colnames(alem_pmids) <- "pmid"
alem_proj <- merge(alem_pmids,exporter_links,by.x="pmid",all.x=TRUE)
alem_proj <- alem_proj[complete.cases(alem_proj),]
alem_proj_ss <- merge(alem_proj,wep,by.x="project_number",by.y="core_project_num",all.x=TRUE)
alem_proj_ss <- alem_proj_ss[complete.cases(alem_proj_ss),]

#Imatinib
imat_pubs <- read.csv("~/NETELabs_CaseStudies/assembly/interim_results/imat_pubref.csv",stringsAsFactors=FALSE)
imat_pmids <- union(imat_pubs$citing_pmid,imat_pubs$cited_pmid)
imat_pmids <- data.frame(imat_pmids)
colnames(imat_pmids) <- "pmid"
imat_proj <- merge(imat_pmids,exporter_links,by.x="pmid",all.x=TRUE)
imat_proj <- imat_proj[complete.cases(imat_proj),]
imat_proj_ss <- merge(imat_proj,wep,by.x="project_number",by.y="core_project_num",all.x=TRUE)
imat_proj_ss <- imat_proj_ss[complete.cases(imat_proj_ss),]

#Nelarabine
nela_pubs <- read.csv("~/NETELabs_CaseStudies/assembly/interim_results/nela_pubref.csv",stringsAsFactors=FALSE)
nela_pmids <- union(nela_pubs$citing_pmid,nela_pubs$cited_pmid)
nela_pmids <- data.frame(nela_pmids)
colnames(nela_pmids) <- "pmid"
nela_proj <- merge(nela_pmids,exporter_links,by.x="pmid",all.x=TRUE)
nela_proj <- nela_proj[complete.cases(nela_proj),]
nela_proj_ss <- merge(nela_proj,wep,by.x="project_number",by.y="core_project_num",all.x=TRUE)
nela_proj_ss <- nela_proj_ss[complete.cases(nela_proj_ss),]

#Ramucirumab
ramu_pubs <- read.csv("~/NETELabs_CaseStudies/assembly/interim_results/ramu_pubref.csv",stringsAsFactors=FALSE)
ramu_pmids <- union(ramu_pubs$citing_pmid,ramu_pubs$cited_pmid)
ramu_pmids <- data.frame(ramu_pmids)
colnames(ramu_pmids) <- "pmid"
ramu_proj <- merge(ramu_pmids,exporter_links,by.x="pmid",all.x=TRUE)
ramu_proj <- ramu_proj[complete.cases(ramu_proj),]
ramu_proj_ss <- merge(ramu_proj,wep,by.x="project_number",by.y="core_project_num",all.x=TRUE)
ramu_proj_ss <- ramu_proj_ss[complete.cases(ramu_proj_ss),]

#Sunitinib
suni_pubs <- read.csv("~/NETELabs_CaseStudies/assembly/interim_results/suni_pubref.csv",stringsAsFactors=FALSE)
suni_pmids <- union(suni_pubs$citing_pmid,suni_pubs$cited_pmid)
suni_pmids <- data.frame(suni_pmids)
colnames(suni_pmids) <- "pmid"
suni_proj <- merge(suni_pmids,exporter_links,by.x="pmid",all.x=TRUE)
suni_proj <- suni_proj[complete.cases(suni_proj),]
suni_proj_ss <- merge(suni_proj,wep,by.x="project_number",by.y="core_project_num",all.x=TRUE)
suni_proj_ss <- suni_proj_ss[complete.cases(suni_proj_ss),]

library(caroline)
write.delim(alem_proj_ss,file="alem_proj_ss.tsv",quote = FALSE, row.names = FALSE, sep = "\t")
write.delim(imat_proj_ss,file="imat_proj_ss.tsv",quote = FALSE, row.names = FALSE, sep = "\t")
write.delim(nela_proj_ss,file="nela_proj_ss.tsv",quote = FALSE, row.names = FALSE, sep = "\t")
write.delim(ramu_proj_ss,file="ramu_proj_ss.tsv",quote = FALSE, row.names = FALSE, sep = "\t")
write.delim(suni_proj_ss,file="suni_proj_ss.tsv",quote = FALSE, row.names = FALSE, sep = "\t")




