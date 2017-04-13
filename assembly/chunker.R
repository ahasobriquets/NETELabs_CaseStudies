#chunker takes two parameters. 
# A vector x and chunk_size y
# Does not handle data frames

chunker <- function(x,y) {
no_of_chunks <- ceiling(length(x)/y)	
print(no_of_chunks)
my_chunks <- list()
a <- 0
	for(i in 1:no_of_chunks) {
			if(i < no_of_chunks) {
			my_chunks[[i]] <- x[(a+1):(a+y)]
			} else {
			my_chunks[[i]] <- x[(a+1):length(x)]}
		a=a+y}
return(my_chunks)}

