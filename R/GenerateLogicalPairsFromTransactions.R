#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  inputPath <- "c:/chgevo"
  #stop("Only one argument must be supplied (path of input files).n", call.=FALSE)
} else {
  inputPath <- args[1]
}

if(! "arules" %in% installed.packages()) install.packages("arules", depend = TRUE)
library(arules)

sink() # clean up in case script crashed inside loop

outputPath <- "arules/"  # where to store the association rules
dir.create(outputPath)

transactionFiles <- list.files(pattern = "\\_commits_UIDs_transactions_renamed\\.csv$", path = inputPath)

for (tFile in transactionFiles) {
  message("processing ", tFile)
  inputFile <- paste(inputPath, tFile, sep="/")
  message("   input file: ", inputFile)
  # transaction ID is in first column
  tmp.file <- read.transactions(inputFile, sep=",", format="basket", cols=c(1) )
  
  tmp.rules <- apriori(tmp.file, parameter=list(supp=0.005,conf=0.01,minlen=2,maxlen=2))
  
  rules.sorted <- sort(tmp.rules, by=(c("support","confidence")))

  # Generate CSV of rules
  outFile <- paste(outputPath, paste(gsub("_commits_UIDs_transactions","",tools::file_path_sans_ext(basename(inputFile))),"_apriori_rules.csv", sep=""),sep="")
  
  write.csv( DATAFRAME(rules.sorted, separate = TRUE), file = outFile)
  
}