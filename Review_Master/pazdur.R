# integrating FDA (Pazdur) reviews into five-pack dataset
setwd("~/NETELabs_CaseStudies/Review_Master/fda")
rm(list=ls())
pazdur_reviews <- read.csv("pazdur_reviews",stringsAsFactors=FALSE)
pub_out <- read.csv("pub_out.csv",stringsAsFactors=FALSE)
colnames(pub_out) <- casefold(colnames(pub_out))
pub_cites <- read.csv("pub_cites.csv",stringsAsFactors=FALSE)
colnames(pub_cites) <- casefold(colnames(pub_cites))
colnames(pub_cites)[2] <- 'pc_sid'
po_fda <- merge(pazdur_reviews,pub_out)
pazdur <- merge(po_fda,pub_cites,by.x="sid",by.y="pubsid")
library(dplyr)
pazdur <- pazdur %>% select(drug,pmid,sid,pc_sid) %>% unique()
pazdur <- merge(pazdur,pub_out,by.x="pc_sid",by.y="sid")
pazdur_a <- pazdur %>% select(drug,pmid=pmid.x,cited_pmid=pmid.y)
pazdur_a <- pazdur_a[!pazdur_a$cited_pmid %in% pazdur_a$pmid,]
pazdur_b <- pazdur_a %>% select(source=pmid,target=drug) %>% 
mutate(stype="review",ttype="root") %>% unique()
pazdur_c <- pazdur_a %>% select(source=drug,target=cited_pmid) %>% 
mutate(stype="root",ttype="pmid1") %>% unique()
pazdur <- rbind(pazdur_b,pazdur_c)
pazdur <- pazdur[complete.cases(pazdur),]
pazdur <- pazdur %>% arrange(stype,source)

alemtuzumab_fda_pazdur <- pazdur %>% filter(source=="alemtuzumab") %>% select(pmid=target) %>% 
unique() 
write.csv(alemtuzumab_fda_pazdur, "~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/alem_rev.csv",row.names=FALSE)
imatinib_fda_pazdur <- pazdur %>% filter(source=="imatinib") %>% select(pmid=target) %>% 
unique() 
write.csv(imatinib_fda_pazdur, "~/NETELabs_CaseStudies/assembly/imatinib_assembly/imat_rev.csv",row.names=FALSE)
nelarabine_fda_pazdur <- pazdur %>% filter(source=="nelarabine") %>% select(pmid=target) %>% 
unique() 
write.csv(nelarabine_fda_pazdur, "~/NETELabs_CaseStudies/assembly/nelarabine_assembly/nela_rev.csv",row.names=FALSE)
ramucirumab_fda_pazdur <- pazdur %>% filter(source=="ramucirumab") %>% select(pmid=target) %>% 
unique() 
write.csv(ramucirumab_fda_pazdur, "~/NETELabs_CaseStudies/assembly/ramucirumab_assembly/ramu_rev.csv",row.names=FALSE)
sunitinib_fda_pazdur <- pazdur %>% filter(source=="sunitinib") %>% select(pmid=target) %>% 
unique()
write.csv(sunitinib_fda_pazdur, "~/NETELabs_CaseStudies/assembly/sunitinib_assembly/suni_rev.csv",row.names=FALSE) 








