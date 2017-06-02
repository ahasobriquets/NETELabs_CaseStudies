# Generate Venn Diagrams for biblio and grant data 
rm(list=ls())
setwd("~/NETELabs_CaseStudies/assembly/interim_results/")
load(".RData")
# else run load_interim_results.R

alem_citing_pmid <- alem_m3$citing_pmid[!is.na(alem_m3$citing_pmid)]
imat_citing_pmid <- imat_m3$citing_pmid[!is.na(imat_m3$citing_pmid)]
nela_citing_pmid <- nela_m3$citing_pmid[!is.na(nela_m3$citing_pmid)]
ramu_citing_pmid <- ramu_m3$citing_pmid[!is.na(ramu_m3$citing_pmid)]
suni_citing_pmid <- suni_m3$citing_pmid[!is.na(suni_m3$citing_pmid)]

alem_cited_pmid <- alem_m3$cited_pmid[!is.na(alem_m3$cited_pmid)]
imat_cited_pmid <- imat_m3$cited_pmid[!is.na(imat_m3$cited_pmid)]
nela_cited_pmid <- nela_m3$cited_pmid[!is.na(nela_m3$cited_pmid)]
ramu_cited_pmid <- ramu_m3$cited_pmid[!is.na(ramu_m3$cited_pmid)]
suni_cited_pmid <- suni_m3$cited_pmid[!is.na(suni_m3$cited_pmid)]

alem_citing_sid <- alem_m3$citing_sid[!is.na(alem_m3$citing_sid)]
imat_citing_sid <- imat_m3$citing_sid[!is.na(imat_m3$citing_sid)]
nela_citing_sid <- nela_m3$citing_sid[!is.na(nela_m3$citing_sid)]
ramu_citing_sid <- ramu_m3$citing_sid[!is.na(ramu_m3$citing_sid)]
suni_citing_sid <- suni_m3$citing_sid[!is.na(suni_m3$citing_sid)]

alem_cited_sid <- alem_m3$cited_sid[!is.na(alem_m3$cited_sid)]
imat_cited_sid <- imat_m3$cited_sid[!is.na(imat_m3$cited_sid)]
nela_cited_sid <- nela_m3$cited_sid[!is.na(nela_m3$cited_sid)]
ramu_cited_sid <- ramu_m3$cited_sid[!is.na(ramu_m3$cited_sid)]
suni_cited_sid <- suni_m3$cited_sid[!is.na(suni_m3$cited_sid)]

citing_pmid_list <- list(
unique(nela_citing_pmid),
unique(ramu_citing_pmid),
unique(suni_citing_pmid),
unique(imat_citing_pmid),
unique(alem_citing_pmid))
names(citing_pmid_list) <- c("nela","ramu","suni","imat","alem")

cited_pmid_list <- list(
unique(alem_cited_pmid),
unique(imat_cited_pmid),
unique(nela_cited_pmid),
unique(ramu_cited_pmid),
unique(suni_cited_pmid))
names(cited_pmid_list) <- c("alem","imat","nela","ramu","suni")

citing_sid_list <- list(
unique(alem_citing_sid),
unique(imat_citing_pmid),
unique(nela_citing_pmid),
unique(ramu_citing_pmid),
unique(suni_citing_sid)) 
names(citing_sid_list) <- c("alem","imat","nela","ramu","suni")

cited_sid_list <- list(
unique(nela_cited_sid),
unique(ramu_cited_sid),
unique(suni_cited_sid),
unique(imat_cited_sid),
unique(alem_cited_sid)
) 
names(cited_sid_list) <- c("nela","ramu","suni","imat","alem")

# list of 5 network interactions in cited references

intersectFiveGen1 <- data.frame(Reduce(intersect,list(nela_citing_sid,ramu_citing_sid,suni_citing_sid,imat_citing_sid,alem_citing_sid)),
stringsAsFactors=FALSE)
colnames(intersectFiveGen1) <- "citing_sid"

intersectFiveGen2 <- data.frame(Reduce(intersect,list(nela_cited_sid,ramu_cited_sid,suni_cited_sid,imat_cited_sid,alem_cited_sid)),
stringsAsFactors=FALSE)
colnames(intersectFiveGen2) <- "cited_sid"

# generate list for Alex
alex_alem <- alem_m3[alem_m3$cited_sid %in% intersectFiveGen2$cited_sid,2:3]
alex_alem <- alex_alem %>% mutate(drug="alem",idiotype=paste("a",citing_sid,sep=""))
alex_imat <- imat_m3[imat_m3$cited_sid %in% intersectFiveGen2$cited_sid,2:3]
alex_imat <- alex_imat %>% mutate(drug="imat",idiotype=paste("i",citing_sid,sep=""))
alex_nela <- nela_m3[nela_m3$cited_sid %in% intersectFiveGen2$cited_sid,2:3]
alex_nela <- alex_nela %>% mutate(drug="nela",idiotype=paste("n",citing_sid,sep=""))
alex_ramu <- ramu_m3[ramu_m3$cited_sid %in% intersectFiveGen2$cited_sid,2:3]
alex_ramu <- alex_ramu %>% mutate(drug="ramu",idiotype=paste("r",citing_sid,sep=""))
alex_suni <- suni_m3[suni_m3$cited_sid %in% intersectFiveGen2$cited_sid,2:3]
alex_suni <- alex_suni %>% mutate(drug="suni",idiotype=paste("s",citing_sid,sep=""))
alex_cscape <- rbind(alex_alem,alex_imat,alex_nela,alex_ramu,alex_suni)
write.csv(alex_cscape,"~/Dropbox/ERNIE_Pico/cytoscape/alex_cscape.csv")








     
     



