# load interim results files into a list
rm(list=ls())
setwd("~/Desktop/Interim_Results")
temp <- list.files()
interim_results <- list()
for (i in 1:length(temp)) {
	interim_results[[i]] <- read.csv(temp[i],stringsAsFactors=FALSE,header=TRUE)
}
names(interim_results) <- temp
rm(i)
pub_out <- interim_results[['pub_out.csv']]
pub_cites <- interim_results[['pub_cites.csv']]
rm(interim_results)
alem <- read.csv("~//NETELabs_CaseStudies/assembly/alemtuzumab_assembly/alem_eric_stage1.csv",
stringsAsFactors=FALSE)
str(pub_out)
str(pub_cites)
str(alem)
imat <- read.csv("~//NETELabs_CaseStudies/assembly/imatinib_assembly/imat_eric_stage1.csv",
stringsAsFactors=FALSE)
nela <- read.csv("~//NETELabs_CaseStudies/assembly/nelarabine_assembly/nela_eric_stage1.csv",
stringsAsFactors=FALSE)
ramu <- read.csv("~//NETELabs_CaseStudies/assembly/ramucirumab_assembly/ramu_eric_stage1.csv",
stringsAsFactors=FALSE)
suni <- read.csv("~//NETELabs_CaseStudies/assembly/sunitinib_assembly/suni_eric_stage1.csv",
stringsAsFactors=FALSE)

alem_m1 <- merge(alem[,2:3],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)
imat_m1 <- merge(imat[,2:3],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)
nela_m1 <- merge(nela[,2:3],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)
ramu_m1 <- merge(ramu[,2:3],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)
suni_m1 <- merge(suni[,2:3],pub_out[,1:2],by.x="id",by.y="PMID",all.x=TRUE)

dim(alem_m1[!complete.cases(alem_m1),])
dim(imat_m1[!complete.cases(imat_m1),])
dim(nela_m1[!complete.cases(nela_m1),])
dim(ramu_m1[!complete.cases(ramu_m1),])
dim(suni_m1[!complete.cases(suni_m1),])

alem_m2 <- merge(alem_m1,pub_cites[,1:2],by.x="SID",by.y="SID",all.x=TRUE)
imat_m2 <- merge(imat_m1,pub_cites[,1:2],by.x="SID",by.y="SID",all.x=TRUE)
nela_m2 <- merge(nela_m1,pub_cites[,1:2],by.x="SID",by.y="SID",all.x=TRUE)
ramu_m2 <- merge(ramu_m1,pub_cites[,1:2],by.x="SID",by.y="SID",all.x=TRUE)
suni_m2 <- merge(suni_m1,pub_cites[,1:2],by.x="SID",by.y="SID",all.x=TRUE)

dim(alem_m2[!complete.cases(alem_m2),])
dim(imat_m2[!complete.cases(imat_m2),])
dim(nela_m2[!complete.cases(nela_m2),])
dim(ramu_m2[!complete.cases(ramu_m2),])
dim(suni_m2[!complete.cases(suni_m2),])


