# Read in ExPorter Project Data from downloaded csvs into a data frame. 
# Because the number of columns changed over the years, we select a subset.

# load exporter projects files into a list
rm(list = ls())

setwd("~/Desktop/ExPORTER/xCleaned")
temp <- list.files(pattern = "*.csv")
exp_projects <- list()
for (i in 1:length(temp)) {
	t <- read.csv(temp[i], stringsAsFactors = FALSE, header = TRUE)
	t <- data.frame(t$APPLICATION_ID, t$ACTIVITY, t$ADMINISTERING_IC, t$APPLICATION_TYPE, t$CORE_PROJECT_NUM, 
		t$FOA_NUMBER, t$FULL_PROJECT_NUM, t$STUDY_SECTION, t$STUDY_SECTION_NAME,stringsAsFactors=FALSE)
	print(temp[i])
	print(ncol(t))
	print(colnames(t))
	exp_projects[[i]] <- t
}
names(exp_projects) <- temp
exp_projects_df <- do.call("rbind", exp_projects)
colnames(exp_projects_df) <- casefold(colnames(exp_projects_df))
colnames(exp_projects_df) <- substring(colnames(exp_projects_df),3)
write.csv(exp_projects_df,file="exp_projects_df.csv",row.names=FALSE)
