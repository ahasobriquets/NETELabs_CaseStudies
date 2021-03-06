# Merge with projects and peer review data

# load interim results files into a list
rm(list=ls())
# Load 9 csv files from Eric Livingston into a list

setwd("~/NETELabs_CaseStudies/assembly/interim_results")
# temp <- list.files(pattern="*.csv")
# interim_results <- list()
# for (i in 1:length(temp)) {
#	interim_results[[i]] <- read.csv(temp[i],stringsAsFactors=FALSE,header=TRUE)
#}
# names(interim_results) <- temp
# rm(i)
# save(interim_results,file="interim_results.RData")

# Read in pub_out (pmid-SID) and pub_cites (PubSID to SID) 

# Clip SourceYear to restrict from 1900-2015.

pub_out <- read.csv("pub_out.csv",colClasses=rep("character",6))
pub_cites <- read.csv("pub_cites.csv",colClasses=rep("character",9))
pub_cites$SourceYear <- as.integer(pub_cites$SourceYear)

library(dplyr)
pub_cites <- pub_cites %>% filter(SourceYear >=1900 & SourceYear <=2015)


# free up memory
# rm(interim_results)
# print str stats
str(pub_out)
str(pub_cites)


# Read in exporter link and projects data
exp_link <- read.csv("~//NETELabs_CaseStudies/assembly/final_results/exporter_links.csv",colClasses=(rep("character",2)))
exp_projects <- read.csv("~//NETELabs_CaseStudies/assembly/final_results/exporter_projects.csv",colClasses=(rep("character",9)))


# load Stage I files that Eric used to generate pub_out and pub_cites
alem <- read.csv("~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/alem_eric_stage1.csv",
colClasses=c(rep("character",9)))
imat <- read.csv("~/NETELabs_CaseStudies/assembly/imatinib_assembly/imat_eric_stage1.csv",
colClasses=c(rep("character",9)))
nela <- read.csv("~/NETELabs_CaseStudies/assembly/nelarabine_assembly/nela_eric_stage1.csv",
colClasses=c(rep("character",9)))
ramu <- read.csv("~/NETELabs_CaseStudies/assembly/ramucirumab_assembly/ramu_eric_stage1.csv",
colClasses=c(rep("character",9)))
suni <- read.csv("~/NETELabs_CaseStudies/assembly/sunitinib_assembly/suni_eric_stage1.csv",
colClasses=c(rep("character",9)))

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
imat_m3 <- imat_m3 %>% mutate(drug="imat") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

nela_m3 <- merge(nela_m2,pub_out[,1:2],by.x="citedSID",by.y="SID",all.x=TRUE)
colnames(nela_m3) <- c("cited_sid","year","citing_pmid","citing_sid","cited_pmid")
nela_m3 <- nela_m3 %>% mutate(drug="nela") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

ramu_m3 <- merge(ramu_m2,pub_out[,1:2],by.x="citedSID",by.y="SID",all.x=TRUE)
colnames(ramu_m3) <- c("cited_sid","year","citing_pmid","citing_sid","cited_pmid")
ramu_m3 <- ramu_m3 %>% mutate(drug="ramu") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

suni_m3 <- merge(suni_m2,pub_out[,1:2],by.x="citedSID",by.y="SID",all.x=TRUE)
colnames(suni_m3) <- c("cited_sid","year","citing_pmid","citing_sid","cited_pmid")
suni_m3 <- suni_m3 %>% mutate(drug="suni") %>% select(citing_pmid,citing_sid,cited_sid,cited_pmid,year,drug)

alem_pre_exp <- data.frame(combined_pmid=unique(union(alem_m3$citing_pmid,alem_m3$cited_pmid)),stringsAsFactors=FALSE)
imat_pre_exp <- data.frame(combined_pmid=unique(union(imat_m3$citing_pmid,imat_m3$cited_pmid)),stringsAsFactors=FALSE)
nela_pre_exp <- data.frame(combined_pmid=unique(union(nela_m3$citing_pmid,nela_m3$cited_pmid)),stringsAsFactors=FALSE)
ramu_pre_exp <- data.frame(combined_pmid=unique(union(ramu_m3$citing_pmid,ramu_m3$cited_pmid)),stringsAsFactors=FALSE)
suni_pre_exp <- data.frame(combined_pmid=unique(union(suni_m3$citing_pmid,suni_m3$cited_pmid)),stringsAsFactors=FALSE)

alem_proj <- merge(alem_pre_exp,exp_link,by.x="combined_pmid",by.y="pmid")
imat_proj <- merge(imat_pre_exp,exp_link,by.x="combined_pmid",by.y="pmid")
nela_proj <- merge(nela_pre_exp,exp_link,by.x="combined_pmid",by.y="pmid")
ramu_proj <- merge(ramu_pre_exp,exp_link,by.x="combined_pmid",by.y="pmid")
suni_proj <- merge(suni_pre_exp,exp_link,by.x="combined_pmid",by.y="pmid")

proj_intersect <- unique(Reduce(intersect,list(alem_proj$project_number,imat_proj$project_number,nela_proj$project_number,ramu_proj$project_number,suni_proj$project_number)))
proj_intersect <- data.frame(proj_number=proj_intersect,stringsAsFactors=FALSE)
proj_intersect <- proj_intersect %>% mutate(IC=substring(proj_number,4,5),Mechanism=substring(proj_number,1,3))
proj_intersect <- proj_intersect %>% mutate(PType=substring(Mechanism,1,1))

proj_union <- unique(Reduce(union,list(alem_proj$project_number,imat_proj$project_number,nela_proj$project_number,ramu_proj$project_number,suni_proj$project_number)))
proj_union <- data.frame(proj_number=proj_union,stringsAsFactors=FALSE)
proj_union <- proj_union %>% mutate(IC=substring(proj_number,4,5),Mechanism=substring(proj_number,1,3))
proj_union <- proj_union %>% mutate(PType=substring(Mechanism,1,1))

# replace NCI subdivisions CM, CO, and SC with CA in IC field
proj_intersect$IC <- gsub("CM","CA",proj_intersect$IC)
proj_intersect$IC <- gsub("CO","CA",proj_intersect$IC)
proj_intersect$IC <- gsub("SC","CA",proj_intersect$IC)

proj_union$IC <- gsub("CM","CA",proj_union$IC)
proj_union$IC <- gsub("CO","CA",proj_union$IC)
proj_union$IC <- gsub("SC","CA",proj_union$IC)


proj_intersect_percent <- proj_intersect %>% group_by(PType) %>% summarize(Count=length(proj_number)) %>% 
mutate(Percent_I=round(100*Count/112)) %>% arrange(desc(Percent_I))
proj_union_percent <- proj_union %>% group_by(PType) %>% summarize(Count=length(proj_number)) %>% 
mutate(Percent_U=round(100*Count/19104)) %>% arrange(desc(Percent_U))
t <- merge(proj_intersect_percent,proj_union_percent,by.x="PType",by.y="PType")

library(ggplot2)
tiff(filename = "proj_percent.tiff",
     width = 7, height = 7, units = "in", pointsize = 12,
     compression = c("none", "rle", "lzw", "jpeg", "zip", "lzw+p", "zip+p"),
     bg = "white", res = 300, type = "quartz")
proj_plot_tiff <- qplot(Percent_I, Percent_U,data=t,color=PType,size=9,xlab="Intersection",ylab="Union") + geom_abline(intercept = 0, slope = 1) + theme_bw() + geom_text(aes(label=PType), size=5,nudge_x=2,nudge_y=0) + theme(legend.position="none") + xlim(0,80) + ylim (0,80)
print(proj_plot_tiff)
dev.off()

png(filename = "proj_percent.png",
     width = 7, height = 7, units = "in", pointsize = 12,
     bg = "white", res = 300, type = "quartz")
proj_plot_png <- qplot(Percent_I, Percent_U,data=t,color=PType,size=9,xlab="Intersection",ylab="Union") + geom_abline(intercept = 0, slope = 1) + theme_bw() + geom_text(aes(label=PType), size=5,nudge_x=2,nudge_y=0) + theme(legend.position="none") + xlim(0,80) + ylim (0,80)
print(proj_plot_png)
dev.off()

system("cp proj_percent.png ../../Paper/plos-latex-template/")

# Study Section Data

w_alem_ss <- merge(alem_proj,exp_projects,by.x="project_number",by.y="core_project_num")
alem_ss <- w_alem_ss %>% select(project_number,study_section, study_section_name) %>% 
unique() %>% mutate(PType=substring(project_number,1,1)) %>% filter(PType=="R" | PType=="P")

w_imat_ss <- merge(imat_proj,exp_projects,by.x="project_number",by.y="core_project_num")
imat_ss <- w_imat_ss %>% select(project_number,study_section, study_section_name) %>% 
unique() %>% mutate(PType=substring(project_number,1,1)) %>% filter(PType=="R" | PType=="P")

w_nela_ss <- merge(nela_proj,exp_projects,by.x="project_number",by.y="core_project_num")
nela_ss <- w_nela_ss %>% select(project_number,study_section, study_section_name) %>% 
unique() %>% mutate(PType=substring(project_number,1,1)) %>% filter(PType=="R" | PType=="P")

w_ramu_ss <- merge(ramu_proj,exp_projects,by.x="project_number",by.y="core_project_num")
ramu_ss <- w_ramu_ss %>% select(project_number,study_section, study_section_name) %>% 
unique() %>% mutate(PType=substring(project_number,1,1)) %>% filter(PType=="R" | PType=="P")

w_suni_ss <- merge(suni_proj,exp_projects,by.x="project_number",by.y="core_project_num")
suni_ss <- w_suni_ss %>% select(project_number,study_section, study_section_name) %>% 
unique() %>% mutate(PType=substring(project_number,1,1)) %>% filter(PType=="R" | PType=="P")

ss_intersect <- sort(Reduce(intersect,list(suni_ss$study_section,ramu_ss$study_section,
nela_ss$study_section,imat_ss$study_section,alem_ss$study_section)))

ss_union <- sort(Reduce(union,list(suni_ss$study_section,ramu_ss$study_section,
nela_ss$study_section,imat_ss$study_section,alem_ss$study_section)))




















