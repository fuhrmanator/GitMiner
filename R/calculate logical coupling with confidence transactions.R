library(arules)

inFile <- file.choose()

# transaction ID is in first column
tmp.file <- read.transactions(inFile, sep=",", format="basket", cols=c(1) )

tmp.rules <- apriori(tmp.file, parameter=list(supp=0.005,conf=0.1,minlen=2,maxlen=2))

rules.sorted <- sort(tmp.rules, by="confidence")

# Generate CSV of rules\
outFile <- paste(gsub("_commits_UIDs_transactions","",tools::file_path_sans_ext(inFile)),"_apriori_rules.csv", sep="")

write.csv( DATAFRAME(rules.sorted, separate = TRUE), file = outFile)