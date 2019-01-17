if(! "arules" %in% installed.packages()) install.packages("arules", depend = TRUE)
library (arules)
if(! "random" %in% installed.packages()) install.packages("random", depend = TRUE)
library(random)

smallItemCount <- 24
smallSampleNames <- as.vector(randomStrings(n=smallItemCount, len=10, unique=TRUE))
shortSamplePaths <- rep("src/", smallItemCount)
smallTmpData <- data.frame(paths=shortSamplePaths,names = smallSampleNames)
smallSampleItems <- interaction(smallTmpData[head(names(smallTmpData))], sep= "")

smallObsCount = 500
smallSampleData <- data.frame(
  X = sample(smallSampleItems, smallObsCount, replace = TRUE),
  Y = sample(smallSampleItems, smallObsCount, replace = TRUE)
)

smallRules <-apriori(smallSampleData, parameter=list(supp=0.005,conf=0.1,minlen=2))

largeItemCount = 578
largeSampleNames <- as.vector(randomStrings(n=largeItemCount, len=10, unique=TRUE))
#longSamplePaths <- rep("modules/junit4/src/test/java/org/powermock/modules/junit4/", largeItemCount)
longSamplePaths <- rep("junit4/", largeItemCount)
bigTmpData <- data.frame(paths=longSamplePaths,names = largeSampleNames)
bigSampleItems <- interaction(bigTmpData[head(names(bigTmpData))], sep= "")

largeObsCount = 250
bigSampleData <- data.frame(
  X = sample(bigSampleItems, largeObsCount, replace = TRUE),
  Y = sample(bigSampleItems, largeObsCount, replace = TRUE)
)

bigRules <-apriori(bigSampleData, parameter=list(supp=0.005,conf=0.1,minlen=2))
