#contingency table of 2x2 where rows are commits, pull reqs and columns are passed and failed builds
dataFrame = read.csv(file="D:\\Documents\\github\\SoftwareEvolution\\assignment4\\R\\test.csv", header=TRUE,sep=',')

f <- function(r) {
	ctable <- matrix(c(r["commit_passed"], r["commit_failed"], r["pr_passed"], r["pr_failed"]), ncol = 2)
	chitest <- chisq.test(ctable)
	pofchisq <- chitest$p.value
	
	print(paste(r["id"], pofchisq, sep=","))
	cat(paste(r["id"], pofchisq, sep=","), file="D:\\Documents\\github\\SoftwareEvolution\\assignment4\\R\\output.csv", append = T, fill = T)
}

apply(dataFrame, 1, f)