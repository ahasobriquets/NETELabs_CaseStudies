# This script takes a downloaded database from drugs@fda and imports the Products.txt file
# into a dataframe. https://www.fda.gov/drugs/informationondrugs/ucm079750.htm
# Then it extracts a single column of ActiveIngredients into a character
# vector and grabs the first word of each string in it, suppresses duplicates, sorts, and does
# minor cleanup. Next it takes all the keywords for a set of publications that are in PubMed
# xm format, and concatenates all the keywords into a single vector with duplicate suppression.
# Lastly, it builds a distance matrix between the two vectors, selects perfect matches and prints
# them out as a sorted list for expert consideration.
# Author: George Chacko
# Date 7/6/2017

drugs <- read.csv("~/Desktop/drugsatfda/Products.txt", stringsAsFactors = FALSE, sep = "\t")
d1 <- casefold(drugs$ActiveIngredient)
library(stringr)
d1 <- word(d1, 1)
d1 <- gsub("\\;$", "", d1)
d1 <- unique(d1)
d1 <- sort(d1)
if (d1[1] == "") {
	d1 <- d1[-1]
}
# test this code
davey <- read.csv("~/Desktop/pub_med_test.csv", stringsAsFactors = FALSE)
davey_trim <- davey[, -c(1:5)]
davey_concat <- vector(mode="character",length=ncol(davey_trim))
for (i in 1:ncol(davey_trim)) {
	davey_concat <- c(davey_concat, davey_trim[, i])
	davey_concat <- unique(davey_concat)
}
if (davey_concat[1] == "") {
	davey_concat <- davey_concat[-1]
}
davey_concat <- sort(davey_concat)

# distance matrix based on Levenshtein distances
davey_dist <- adist(d1, davey_concat)
# perfect matches
perfect_hits <- which(davey_dist == 0, arr.ind = T)
# Print Output
print(paste("Number of exact matches is", length(perfect_hits[, 1]), sep = " "))
print(paste("Number of exact matches is", length(perfect_hits[, 1]), sep = " "))
print(paste("Number of exact matches is", length(perfect_hits[, 1]), sep = " "))

# create vector of results
final <- vector(mode = "character", length = length(perfect_hits[, 1]))
for (i in 1:length(perfect_hits[, 1])) {
	final[i] <- davey_concat[perfect_hits[i, 2]]
}
final <- sort(final)
print(final)


