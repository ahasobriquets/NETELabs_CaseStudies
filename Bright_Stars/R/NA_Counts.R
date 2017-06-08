# Counting NAs for cited_sids
rm(list=ls())
setwd("~/NETELabs_CaseStudies/assembly/interim_results")
alem_pubref <- read.csv("alem_pubref.csv",stringsAsFactors=FALSE)
imat_pubref <- read.csv("imat_pubref.csv",stringsAsFactors=FALSE)
nela_pubref <- read.csv("nela_pubref.csv",stringsAsFactors=FALSE)
ramu_pubref <- read.csv("ramu_pubref.csv",stringsAsFactors=FALSE)
suni_pubref <- read.csv("suni_pubref.csv",stringsAsFactors=FALSE)
setwd("~/NETELabs_CaseStudies/assembly/final_results")


alem_cited_NA <- round(100*(sum(is.na(alem_pubref$cited_sid))/length(alem_pubref$cited_sid)),0)

print(alem_cited_NA)
imat_cited_NA <- round(100*(sum(is.na(imat_pubref$cited_sid))/length(imat_pubref$cited_sid)),0)
print(imat_cited_NA)

nela_cited_NA <- round(100*(sum(is.na(nela_pubref$cited_sid))/length(nela_pubref$cited_sid)),0)

print(nela_cited_NA)
ramu_cited_NA <- round(100*(sum(is.na(ramu_pubref$cited_sid))/length(ramu_pubref$cited_sid)),0)
print(ramu_cited_NA)

suni_cited_NA <- round(100*(sum(is.na(suni_pubref$cited_sid))/length(suni_pubref$cited_sid)),0)
print(suni_cited_NA)
