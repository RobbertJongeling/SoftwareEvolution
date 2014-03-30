#read input
dataFrame = read.csv(file="D:\\Documents\\github\\SoftwareEvolution\\assignment4\\output.csv", header=TRUE,sep=',')

#function doing all the work
f <- function(r) {
	#create contingency table, map strings as read from csv to numeric
	x <- c(r["commit_passed"], r["pr_passed"], r["commit_failed"], r["pr_failed"])
	x <- as.numeric(x)
	ctable <- matrix(x, ncol = 2)
	
	#perform chi test on contingency table
	chitest <- chisq.test(ctable)
	pofchisq <- chitest$p.value
	
	#calculate residuals, odds ratio and its p-value
	res <- chitest$residuals
	or <- oddsratio(x)
	oddsRatio <- or$measure[2,1]
	pValue <- or$p.value[2,1]
	
	#perform output
	#print(paste(r["owner"], r["name"], pofchisq, res[1,1], res[1,2], res[2,1], res[2,2], oddsRatio, pValue, sep=","))
	cat(paste(r["owner"], r["name"], pofchisq, res[1,1], res[1,2], res[2,1], res[2,2], oddsRatio, pValue, sep=","), file="D:\\Documents\\github\\SoftwareEvolution\\assignment4\\R\\Routput.csv", append = T, fill = T)
}

#applying the function to the input
apply(dataFrame, 1, f)