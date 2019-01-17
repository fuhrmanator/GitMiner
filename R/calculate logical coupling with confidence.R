library(arules)
library(data.table)

inFile <- file.choose()

labelPattern <- "Class_[12]="

tmp.file <- read.csv(inFile, header=TRUE, sep=",")
tmp.file$Project <- NULL
tmp.file$Commit_ID <- NULL
tmp.file$Revision.ID <- NULL
tmp.file$Revision_number <- NULL

#tmp.rules <- apriori(tmp.file, parameter=list(supp=0.005,conf=0.1,minlen=2))

rules.sorted <- sort(apriori(tmp.file, parameter=list(supp=0.005,conf=0.1,minlen=2)), by="confidence")

# r <- head(rules.sorted,3)
# f <- function(x, fun) unlist(as(fun(x), "list")) ( dt <- data.table(lhs=f(r, lhs), rhs=f(r, rhs)) )

ruleOutput <- data.frame(lhs = labels(lhs(rules.sorted), setStart = "", setEnd = ""), 
           rhs = labels(rhs(rules.sorted), setStart = "", setEnd = ""))

ruleOutput <- cbind(ruleOutput, quality(rules.sorted))

outFile <- paste(gsub("_commits_UIDs_logicalcoupling","",tools::file_path_sans_ext(inFile)),"_apriori_rules_by_pairs.csv", sep="")

write.csv(ruleOutput, file = outFile)

# # get the LHS and RHS as columns
# myLhs <- lhs(rules.sorted)
# myLhsList <- as(myLhs, "list")
# myLhsListUnnamed <- gsub(pattern = labelPattern, replacement = "", myLhsList)
# 
# myRhs <- rhs(rules.sorted)
# myRhsList <- as(myRhs, "list")
# myRhsListUnnamed <- gsub(pattern = labelPattern, replacement = "", myRhsList)
# 
# logicalCouplingData <- rules.sorted@quality
# logicalCouplingData["From_Class"] <- myLhsListUnnamed
# logicalCouplingData["To_Class"] <- myRhsListUnnamed
# 
