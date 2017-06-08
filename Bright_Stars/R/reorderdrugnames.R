# Takes intersection matrix from Keserci and reorder the drug
# abbrevations alphabetically

t <- read.csv("~/Dropbox/ERNIE_Pico/intersectMatrix.csv",stringsAsFactors=FALSE)
t$no_of_drugs <- rowSums(t[,1:5])
t$abbreviation <- toupper(t$abbreviation)
library(dplyr)
t[t=="0"] <- ""
t[t=="1"] <- "X"
t$no_of_drugs[t$no_of_drugs=="X"] <- 1
colnames(t) <- c("alem(A)","imat,(I)","nela(N)","ramu(R)","suni(S)","Combination","Count","No_Of_Drugs" )
t <- t[,c(1:5,6,8,7)]
t <- t %>% arrange(desc(No_Of_Drugs,desc(Intersection)))
t1 <- (strsplit(t$Combination,""))
for (i in 1:length(t1)){
	t2<-sort(t1[[i]])
	t2<-paste(t2,collapse="")
	t1[[i]]<- t2}
t1 <- unlist(t1)
t$Combination <- t1
library(xtable)
xtable(t)
