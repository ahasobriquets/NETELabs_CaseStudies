# This script flattens Eric's data pulls to generate
# a list of pmid1s derived from reviews about our five case studies.

setwd("~/NETELabs_CaseStudies/Review_Master")
load(".RData")
rm(list=ls())

# review_master is a list of review articles one year post-NDA/BLA
review_master <- read.csv("review_master.csv",stringsAsFactors=FALSE)
# reducing to essential columns- drug and pmid only
working_review_master <- review_master[,1:2]

# pub_out is Eric's mapping of pmid to Scopus ID
pub_out <- read.csv("pub_out.csv",stringsAsFactors=FALSE)
colnames(pub_out) <- casefold(colnames(pub_out))

# pub_cites is Eric's mapping of review articles to cited references
pub_cites <- read.csv("pub_cites.csv",stringsAsFactors=FALSE)
colnames(pub_cites) <- casefold(colnames(pub_cites))

save.image()
# subset to those pmids for which Scopus data is available (179/182 pmids)
wrm <- working_review_master[review_master$pmid %in% pub_out$pmid,]

# merge wrm with pub_out using pmids for 'by' field
wrm_po <- merge(wrm,pub_out)

# merge wrm_po with pub_cites field using sid and pubsid
colnames(pub_cites)[2] <- 'pc_sid'
review_cites <- merge(wrm_po,pub_cites,by.x="sid",by.y="pubsid")

library(dplyr)
# reduce review_cites to essential columns only
wrc <- review_cites %>% select(drug,pmid,sid,pc_sid) %>% unique()

# map pc_sid back to pmid and clean up
final_table <- merge(wrc,pub_out,by.x="pc_sid",by.y="sid")
final_table <- final_table %>% select(drug,pmid=pmid.x,sid,pc_sid,cited_pmid=pmid.y)
#eliminate rows with NA
final_table <- final_table[complete.cases(final_table),]
# reorder by drug name 
final_table <- final_table %>% arrange(drug) %>% unique()

# rewrite in network syntax with new node type of "review"
final_table_a <- final_table %>% select(pmid,cited_pmid,drug)
final_table_b <- final_table_a %>% mutate(stype="review",ttype="root") %>% select(source=pmid,stype,target=drug,ttype) %>% unique()
final_table_c <- final_table_a %>% mutate(stype="root",ttype="pmid1") %>% select(source=drug,stype,target=cited_pmid,ttype) %>% unique()
final_table <- rbind(final_table_b,final_table_c) 
final_table <- final_table %>% unique()

alem_rev <- final_table %>% filter(source=="alemtuzumab")
write.csv(alem_rev,file="~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/alem_rev.csv",
row.names=FALSE)

imat_rev <- final_table %>% filter(source=="alemtuzumab")
write.csv(imat_rev,file="~/NETELabs_CaseStudies/assembly/imatinib_assembly/imat_rev.csv",
row.names=FALSE)
