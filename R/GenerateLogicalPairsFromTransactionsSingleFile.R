#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)==1) {
  tFile <- args[1]
} else {
  stop("One argument must be supplied (path of input file).n", call.=FALSE)
}

if(! "arules" %in% installed.packages()) install.packages("arules", depend = TRUE)
library(arules)

sink() # clean up in case script crashed inside loop

outputPath <- "arules/"  # where to store the association rules
dir.create(outputPath)

message("processing ", tFile)
inputFile <- tFile
message("   input file: ", inputFile)
# transaction ID is in first column
tmp.file <- read.transactions(inputFile, sep=",", format="basket", cols=c(1) )

tmp.rules <- apriori(tmp.file, parameter=list(supp=0.0001,conf=0.0001,minlen=2,maxlen=2))

rules.sorted <- sort(tmp.rules, by=(c("support","confidence")))

# Generate CSV of rules
outFile <- paste(outputPath, paste(gsub("_commits_UIDs_transactions","",tools::file_path_sans_ext(basename(inputFile))),"_apriori_rules.csv", sep=""),sep="")
  
write.csv( DATAFRAME(rules.sorted, separate = TRUE), file = outFile)