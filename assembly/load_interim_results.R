# load interim results files into a list
rm(list=ls())
# Load 9 csv files from Eric Livingston into a list

setwd("~/NETELabs_CaseStudies/assembly/interim_results")
temp <- list.files(pattern="*.csv")
interim_results <- list()
for (i in 1:length(temp)) {
	interim_results[[i]] <- read.csv(temp[i],stringsAsFactors=FALSE,header=TRUE)
}
names(interim_results) <- temp
rm(i)
save(interim_results,file="interim_results.RData")

# Extract pub_out (pmid-SID) and pub_cites (PubSID to SID) from list as data frames
pub_out <- interim_results[['pub_out.csv']]
pub_cites <- interim_results[['pub_cites.csv']]
# free up memory
rm(interim_results)
# print str stats
str(pub_out)
str(pub_cites)

# load Stage I files that Eric used to generate pub_out and pub_cites
alem <- read.csv("~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/alem_eric_stage1.csv",
stringsAsFactors=FALSE)
imat <- read.csv("~/NETELabs_CaseStudies/assembly/imatinib_assembly/imat_eric_stage1.csv",
stringsAsFactors=FALSE)
nela <- read.csv("~/NETELabs_CaseStudies/assembly/nelarabine_assembly/nela_eric_stage1.csv",
stringsAsFactors=FALSE)
ramu <- read.csv("~/NETELabs_CaseStudies/assembly/ramucirumab_assembly/ramu_eric_stage1.csv",
stringsAsFactors=FALSE)
suni <- read.csv("~/NETELabs_CaseStudies/assembly/sunitinib_assembly/suni_eric_stage1.csv",
stringsAsFactors=FALSE)

# merge with pub_out to get corresponding SIDs
alem_m1 <- merge(alem[,c(2,8)],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)
imat_m1 <- merge(imat[,c(2,8)],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)
nela_m1 <- merge(nela[,c(2,8)],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)
ramu_m1 <- merge(ramu[,c(2,8)],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)
suni_m1 <- merge(suni[,c(2,8)],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)

dim(alem_m1[!complete.cases(alem_m1),])
dim(imat_m1[!complete.cases(imat_m1),])
dim(nela_m1[!complete.cases(nela_m1),])
dim(ramu_m1[!complete.cases(ramu_m1),])
dim(suni_m1[!complete.cases(suni_m1),])

# fix column name uncertainty
# from here on we use "citingSID" and "citedSID"
colvec <- colnames(pub_cites)
colvec[1] <- "citingSID"
colvec[2] <- "citedSID"
colnames(pub_cites) <- colvec

alem_m2 <- merge(alem_m1,pub_cites[,1:2],by.x="SID",by.y="citingSID",all.x=TRUE)
imat_m2 <- merge(imat_m1,pub_cites[,1:2],by.x="SID",by.y="citingSID",all.x=TRUE)
nela_m2 <- merge(nela_m1,pub_cites[,1:2],by.x="SID",by.y="citingSID",all.x=TRUE)
ramu_m2 <- merge(ramu_m1,pub_cites[,1:2],by.x="SID",by.y="citingSID",all.x=TRUE)
suni_m2 <- merge(suni_m1,pub_cites[,1:2],by.x="SID",by.y="citingSID",all.x=TRUE)

# rearrange columns and change column names for better comprehension
library(dplyr)
alem_m2 <- alem_m2 %>% select(year, pmid=id,citingSID=SID,citedSID)
imat_m2 <- imat_m2 %>% select(year, pmid=id,citingSID=SID,citedSID,year)
nela_m2 <- nela_m2 %>% select(year, pmid=id,citingSID=SID,citedSID,year)
ramu_m2 <- ramu_m2 %>% select(year, pmid=id,citingSID=SID,citedSID,year)
suni_m2 <- suni_m2 %>% select(year, pmid=id,citingSID=SID,citedSID,year)

dim(alem_m2[!complete.cases(alem_m2),])
dim(imat_m2[!complete.cases(imat_m2),])
dim(nela_m2[!complete.cases(nela_m2),])
dim(ramu_m2[!complete.cases(ramu_m2),])
dim(suni_m2[!complete.cases(suni_m2),])

paste ("Total alemtuzumab rows", nrow(alem_m2))
paste("Missing values for alemtuzumab"," ", round(nrow(alem_m2[!complete.cases(alem_m2),])/nrow(alem_m2)*100,2),"%",sep="")
paste ("Total Imatinib rows", nrow(imat_m2))
paste("Missing values for imatinib", " ", round(nrow(imat_m2[!complete.cases(imat_m2),])/nrow(imat_m2)*100,2),"%",sep="")
paste ("Total Nelarabine rows", nrow(nela_m2))
paste("Missing values for nelarabine", " ",round(nrow(nela_m2[!complete.cases(nela_m2),])/nrow(nela_m2)*100,2),"%",sep="")
paste ("Total Ramucirumab rows", nrow(ramu_m2))
paste("Missing values for ramucirumab"," ", round(nrow(ramu_m2[!complete.cases(ramu_m2),])/nrow(ramu_m2)*100,2),"%",sep="")
paste ("Total Sunitinib rows", nrow(suni_m2))
paste("Missing values for sunitinib", " ", round(nrow(suni_m2[!complete.cases(suni_m2),])/nrow(suni_m2)*100,2),"%",sep="")

alem_m3 <- merge(alem_m2,pub_out[,1:2],by.x="citedSID",by.y="SID",all.x=TRUE)
colnames(alem_m3) <- c("cited_sid","year","citing_pmid","citing_sid","cited_pmid")
alem_m3 <- alem_m3 %>% mutate(drug="alem") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

imat_m3 <- merge(imat_m2,pub_out[,1:2],by.x="citedSID",by.y="SID",all.x=TRUE)
colnames(imat_m3) <- c("cited_sid","year","citing_pmid","citing_sid","cited_pmid")
imat_m3 <- alem_m3 %>% mutate(drug="imat") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

nela_m3 <- merge(nela_m2,pub_out[,1:2],by.x="citedSID",by.y="SID",all.x=TRUE)
colnames(nela_m3) <- c("cited_sid","year","citing_pmid","citing_sid","cited_pmid")
nela_m3 <- nela_m3 %>% mutate(drug="nela") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

ramu_m3 <- merge(ramu_m2,pub_out[,1:2],by.x="citedSID",by.y="SID",all.x=TRUE)
colnames(ramu_m3) <- c("cited_sid","year","citing_pmid","citing_sid","cited_pmid")
ramu_m3 <- ramu_m3 %>% mutate(drug="ramu") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

suni_m3 <- merge(suni_m2,pub_out[,1:2],by.x="citedSID",by.y="SID",all.x=TRUE)
colnames(suni_m3) <- c("cited_sid","year","citing_pmid","citing_sid","cited_pmid")
suni_m3 <- suni_m3 %>% mutate(drug="suni") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

write.csv(alem_m3,file="alem_pubref.csv")
write.csv(imat_m3,file="imat_pubref.csv")
write.csv(nela_m3,file="nela_pubref.csv")
write.csv(ramu_m3,file="ramu_pubref.csv")
write.csv(suni_m3,file="suni_pubref.csv")


