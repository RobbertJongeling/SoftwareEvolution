#load lib
library("epitools")

#read input
dataFrame = read.csv(file="D:\\Documents\\github\\SoftwareEvolution\\assignment4\\R\\test.csv", header=TRUE,sep=',')

#function doing all the work
f <- function(r) {
	
	if(r["relevant"] == "true") {	
		#create contingency table, map strings as read from csv to numeric
		x <- c(r["commit_passed"], r["pr_passed"], r["commit_failed"], r["pr_failed"])
		x <- as.numeric(x)
		ctable <- matrix(x, ncol = 2)
		
		#perform chi test on contingency table
		chitest <- chisq.test(ctable)
		pofchisq <- chitest$p.value
		
		#calculate residuals, odds ratio and its p-value
		res <- chitest$residuals
		res11 <- res[1,1]
		res12 <- res[1,2]
		res21 <- res[2,1]
		res22 <- res[2,2]
		or <- oddsratio(x)
		oddsRatio <- or$measure[2,1]
		pValue <- or$p.value[2,1]	
	} else {
		pofchisq <- "NA"
		res11 <- "NA"
		res12 <- "NA"
		res21 <- "NA"
		res22 <- "NA"
		oddsRatio <- "NA"
		pValue <- "NA"
	}
	#perform output
	#print(paste(r["ghtorrent_id"], pofchisq, res11, res12, res21, res22, oddsRatio, pValue, sep=","))
	cat(paste(r["ghtorrent_id"], pofchisq, res11, res12, res21, res22, oddsRatio, pValue, sep=","), file="D:\\Documents\\github\\SoftwareEvolution\\assignment4\\R\\Routputtest.csv", append = T, fill = T)
}

#applying the function to the input
apply(dataFrame, 1, f)