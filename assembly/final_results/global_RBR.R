# Calculate Global RBR

setwd("~/Dropbox/ERNIE_Pico/globalscores/")
temp <- list.files(pattern="*.csv")
rbr_list <- list()
for (i in 1:length(temp)) {
	rbr_list[[i]] <- read.csv(temp[i],stringsAsFactors=FALSE,header=TRUE)
}
names(rbr_list) <- temp
rm(i)

alem_gRBR_at <- rbr_list[[1]]
global_author_list <- rbr_list[[2]]
imat_gRBR_at <- rbr_list[[3]]
nela_gRBR_at <- rbr_list[[4]]
ramu_gRBR_at <- rbr_list[[5]]
suni_gRBR_at <- rbr_list[[6]]

global_author_list <- global_author_list[,c(1,24)]

temp_alem_gRBR_at <- alem_gRBR_at[,c(1,3,4)]
temp_imat_gRBR_at <- imat_gRBR_at[,c(1,3,4)]
temp_nela_gRBR_at <- nela_gRBR_at[,c(1,3,4)]
temp_ramu_gRBR_at <- ramu_gRBR_at[,c(1,3,4)]
temp_suni_gRBR_at <- suni_gRBR_at[,c(1,3,4)]

global_doc_counts <- rbind(temp_alem_gRBR_at,temp_imat_gRBR_at,temp_nela_gRBR_at,temp_ramu_gRBR_at,temp_suni_gRBR_at)
global_doc_counts <- unique(global_doc_counts)

global_RBR <- merge(global_doc_counts,global_author_list,by.x="auth",by.y="authSID")

library(dplyr)

global_RBR <-  global_RBR %>% select(authSID=auth,globalInDegree,article_count,total_docCount) %>%
mutate(global_RBR_a=globalInDegree/article_count,global_RBR_t=globalInDegree/total_docCount) %>%
arrange(desc(global_RBR_a))

print(paste("The total number of rows is",nrow(global_RBR)))
print(paste("The number of infinity values in global_RBR_a is",nrow(global_RBR[global_RBR$global_RBR_a==Inf,])))
print(paste("The number of values where global_RBR_a >1 is",nrow(global_RBR[global_RBR$global_RBR_a>1,])))

global_RBR <- global_RBR[global_RBR$global_RBR_a!=Inf,]
global_RBR <- global_RBR[global_RBR$global_RBR_a<=1,]






