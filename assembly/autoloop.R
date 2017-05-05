autoloop <- function(a,b){
# where a is a correctly pathed directory that contains 7 files
# where b is a case study name, e.g. sunitinib

# List of input files.
# sunitinib_ct_nct.csv (two column, header is nct_id, pmid)
# sunitinib_ct_pubmed.csv (single column, header is pmid)
# sunitinib_fda_pazdur.csv (single column, header is pmid)
# sunitinib_fda_review.csv (single column, header is pmid)
# sunitinib_patent_npl.csv (single column, header is pmid)
# sunitinib_pubmed.csv (single column, header is pmid)
# suni_rev.csv (product of ~/NETELabs_CaseStudies/Review_Master/load_core_citation_data.R)

setwd(a)
a <- dir()
a <- sort(a)
print(a)

print(paste("Assembling Stage I Data for, ",b,sep=""))
# read in csv files and insert into a list
core_set <- list()
if(file.exists(paste(b,"_ct_nct.csv",sep=""))) {
	t1 <- paste(b,"_ct_nct.csv",sep="")
	core_set[[1]] <- read.csv(t1,stringsAsFactors=FALSE)
	} else {break}
if(file.exists(paste(b,"_ct_pubmed.csv",sep=""))) {
	t1 <- paste(b,"_ct_pubmed.csv",sep="")
	core_set[[2]] <- read.csv(t1,stringsAsFactors=FALSE)
	} else {break}
if(file.exists(paste(b,"_fda_pazdur.csv",sep=""))) {
	t1 <- paste(b,"_fda_pazdur.csv",sep="")
	core_set[[3]] <- read.csv(t1,stringsAsFactors=FALSE)
	} else {break}
if(file.exists(paste(b,"_fda_review.csv",sep=""))) {
	t1 <- paste(b,"_fda_review.csv",sep="")
	core_set[[4]] <- read.csv(t1,stringsAsFactors=FALSE)
	} else {break}
if(file.exists(paste(b,"_patent_npl.csv",sep=""))) {
	t1 <- paste(b,"_patent_npl.csv",sep="")
	core_set[[5]] <- read.csv(t1,stringsAsFactors=FALSE)
	} else {break}
if(file.exists(paste(b,"_pubmed.csv",sep=""))) {
	t1 <- paste(b,"_pubmed.csv",sep="")
	core_set[[6]] <- read.csv(t1,stringsAsFactors=FALSE)
	} else {break}
if(file.exists(paste(substring(b,1,4),"_rev.csv",sep=""))) {
	t1 <- paste(substring(b,1,4),"_rev.csv",sep="")
	core_set[[7]] <- read.csv(t1,stringsAsFactors=FALSE)
	} else {break}
return(core_set)
}

# Metadata file 
# sunitinib_metadata

setwd("~/NETELabs_CaseStudies/assembly/sunitinib_assembly/")
# system("git pull")
rm(list=ls())
library(dplyr)
## Clinical Trials Component
#  Root to pubmed_derived clinical trials 
suni_ct_pubmed <- read.csv("sunitinib_ct_pubmed.csv",stringsAsFactors=FALSE)
suni_ct1 <- suni_ct_pubmed %>% mutate(source="sunitinib",stype="root",
target=paste(pmid,"_ct",sep=""),ttype="ct") %>% select(source,stype,target,ttype)
# pmid_ct to pmid1
suni_ct2 <- suni_ct_pubmed %>% mutate(source=paste(pmid,"_ct",sep=""),stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

# Root to nct_derived clinical trials
suni_ct_nct <- read.csv("sunitinib_ct_nct.csv",stringsAsFactors=FALSE)

suni_ct3 <- suni_ct_nct %>% mutate(source="sunitinib",stype="root",
target=nct_id,ttype="ct") %>% select(source,stype,target,ttype)
# nct to pmid1
suni_ct4 <- suni_ct_nct %>% mutate(source=nct_id,stype="ct",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 

## FDA Component
# Scraped Medical Review derived
suni_fda_review <- read.csv("sunitinib_fda_review.csv",stringsAsFactors=FALSE)
suni_fda1 <- suni_fda_review %>% mutate(source="nda_21938",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype) 
# FDA Approval Summary derived (Pazdur)
suni_fda_pazdur <- read.csv("sunitinib_fda_pazdur.csv",stringsAsFactors=FALSE)
suni_fda2 <- suni_fda_pazdur %>% mutate(source="nda_21938",stype="fda",target=pmid,
ttype="pmid1") %>% select(source,stype,target,ttype)
suni_fda3 <- c("sunitinib","root","nda_21938","fda")

## Patent Component
suni_patent <- read.csv("sunitinib_patent_npl.csv",stringsAsFactors=FALSE)
suni_patent1 <- suni_patent %>% mutate(source="us6573293",stype="patent",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
suni_patent2 <- c("sunitinib","root","us6573293","patent")

## Pubmed Component
suni_pmid1 <- read.csv("sunitinib_pubmed.csv",stringsAsFactors=FALSE)
suni_pmid1_1 <- suni_pmid1 %>% mutate(source="sunitinib",stype="root",
target=pmid,ttype="pmid1") %>% select(source,stype,target,ttype)
# reads csv file from load_core_citation_data script run at beginnning
suni_pmid1_2 <- read.csv("suni_rev.csv",stringsAsFactors=FALSE)

## Merge all components
suni_merge1 <-rbind(suni_ct1,suni_ct2,suni_ct3,suni_ct4,
suni_fda1,suni_fda2,suni_fda3,
suni_patent1,suni_patent2,
suni_pmid1_1,suni_pmid1_2)
suni_merge1 %>% arrange(desc(stype)) %>% unique()
write.csv(suni_merge1,file="suni_merge1.csv")

## Generate a list of unique pmids for Eric
suni_eric1 <- suni_merge1 %>% filter(ttype=="pmid1") %>% 
select(target) %>% unique()
suni_eric1 <- na.omit(suni_eric1)
print(dim(suni_eric1))

setwd("~/Desktop")

## Format list per Eric's specs using rentrez in chunks
## 


#chunker takes two parameters and chunks a vector x into y sized chunks 
# and insert them into a list. Returns a list named my_chunks
# A vector x and chunk_size y
# Does not handle data frames

chunker <- function(x,y) {
no_of_chunks <- ceiling(length(x)/y)	
print(no_of_chunks)
# data checks for x & y
if (is.vector(x)!=TRUE) {break}
if (all(x == as.integer(x))!=TRUE) {break}
if (all(y == as.integer(y))!=TRUE) {break}

my_chunks <- list()
a <- 0
	for(i in 1:no_of_chunks) {
			if(i < no_of_chunks) {
			my_chunks[[i]] <- x[(a+1):(a+y)]
			} else {
			my_chunks[[i]] <- x[(a+1):length(x)]}
		a=a+y}
names(my_chunks) <- paste("my_chunks", 1:no_of_chunks, sep = "")
return(my_chunks)}

x <- suni_eric1$target
y <- 400

my_chunks <- chunker(x,y)

# submit to ncbi e_utils
# takes elements from my_chunks and submits them to NCBI then creates esummary, a list of lists, 
# from the returned data 
library(rentrez)
namevec <- names(my_chunks)
esummary <- list()
for (i in 1:length(namevec)) {
	esummary[[i]] <- entrez_summary(db="pubmed",id=my_chunks[[i]])
	Sys.sleep(60)
}

ericFormat <- function(t) {
# this function takes a list as input and generates a data frame 
# with seven columns as output. The input list is generated by 
# an entrez_summary function that in turn takes an input vector of pmids
# to generate a list as ouput.

	a <- unname(sapply(t, function(x) x$uid))
	b <- unname(sapply(t, function(x) x$pubdate))
	c <- unname(sapply(t,function(x) x$sortfirstauthor))
	d <- unname(sapply(t, function(x) x$lastauthor))
	e <- unname(sapply(t, function(x) x$fulljournalname))
	f <- unname(sapply(t,function(x) x$title))
	g <- as.integer(substring(b,1,4))
	h <- data.frame(cbind(a, b, c, d, e, f,g), stringsAsFactors = FALSE)
		colnames(h) <- c("id","pubdate","firstauthor","lastauthor","source","title","year")
	return(h)}

#flatten to dataframe using ericFormat
flattened_summary <- list()
for (i in 1:length(namevec)) {
	flattened_summary[[i]] <- ericFormat(esummary[[i]])
}
# Write out final output for eric
suni_eric_stage1 <- do.call("rbind",flattened_summary)
suni_eric_stage1 <- suni_eric_stage1 %>% mutate(drug_name="sunitinib")
write.csv(suni_eric_stage1,file="suni_eric_stage1.csv")














