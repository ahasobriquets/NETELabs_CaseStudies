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

library(gplots)

tiff(filename = "citing_pmid.tiff",
     width = 7, height = 7, units = "in", pointsize = 12,
     compression = c("none", "rle", "lzw", "jpeg", "zip", "lzw+p", "zip+p"),
     bg = "white", res = 300, type = "quartz")
venn(citing_pmid_list)
dev.off()

tiff(filename = "cited_sid.tiff",
     width = 7, height = 7, units = "in", pointsize = 12,
     compression = c("none", "rle", "lzw", "jpeg", "zip", "lzw+p", "zip+p"),
     bg = "white", res = 300, type = "quartz")
venn(cited_sid_list)
dev.off()

png(filename = "citing_pmid.png",
     width = 7, height = 7, units = "in", pointsize = 12,
     bg = "white", res = 300, type = "quartz")
venn(citing_pmid_list)
dev.off()

png(filename = "cited_sid.png",
     width = 7, height = 7, units = "in", pointsize = 12,
     bg = "white", res = 300, type = "quartz")
venn(cited_sid_list)
dev.off()

# based on visual inspection of the images...

is.na(Reduce(intersect,list(nela_citing_pmid,ramu_citing_pmid,suni_citing_pmid,imat_citing_pmid)))
is.na(iReduce(intersect,list(nela_citing_pmid,ramu_citing_pmid,suni_citing_pmid,alem_citing_pmid))
is.na(Reduce(intersect,list(nela_citing_pmid,ramu_citing_pmid,imat_citing_pmid,alem_citing_pmid)))
is.na(Reduce(intersect,list(nela_citing_pmid,suni_citing_pmid,imat_citing_pmid,alem_citing_pmid)))
is.na(Reduce(intersect,list(ramu_citing_pmid,suni_citing_pmid,imat_citing_pmid,alem_citing_pmid)))

Reduce(intersect,list(nela_citing_pmid,ramu_citing_pmid,suni_citing_pmid,imat_citing_pmid))
Reduce(intersect,list(nela_citing_pmid,ramu_citing_pmid,suni_citing_pmid,alem_citing_pmid))
Reduce(intersect,list(nela_citing_pmid,ramu_citing_pmid,imat_citing_pmid,alem_citing_pmid))
Reduce(intersect,list(nela_citing_pmid,suni_citing_pmid,imat_citing_pmid,alem_citing_pmid))
Reduce(intersect,list(ramu_citing_pmid,suni_citing_pmid,imat_citing_pmid,alem_citing_pmid))

# sum of 4 network intersections in cited references
sum(length(Reduce(intersect,list(nela_cited_sid,ramu_cited_sid,suni_cited_sid,imat_cited_sid)))+
length(Reduce(intersect,list(nela_cited_sid,ramu_cited_sid,suni_cited_sid,alem_cited_sid)))+
length(Reduce(intersect,list(nela_cited_sid,ramu_cited_sid,imat_cited_sid,alem_cited_sid)))+
length(Reduce(intersect,list(nela_cited_sid,suni_cited_sid,imat_cited_sid,alem_cited_sid)))+
length(Reduce(intersect,list(ramu_cited_sid,suni_cited_sid,imat_cited_sid,alem_cited_sid))))

# list of 5 network interactions in cited references

intersectFiveGen1 <- data.frame(Reduce(intersect,list(nela_citing_sid,ramu_citing_sid,suni_citing_sid,imat_citing_sid,alem_citing_sid)),
stringsAsFactors=FALSE)
colnames(intersectFiveGen1) <- "citing_sid"


intersectFiveGen2 <- data.frame(Reduce(intersect,list(nela_cited_sid,ramu_cited_sid,suni_cited_sid,imat_cited_sid,alem_cited_sid)),
stringsAsFactors=FALSE)
colnames(intersectFiveGen2) <- "cited_sid"








     
     



