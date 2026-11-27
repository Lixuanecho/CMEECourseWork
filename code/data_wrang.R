# Language: R
# Script: data_wrang.R
# Des: Wrangle the Pound Hill dataset from wide to long form with reshape2::melt()
#      (the course's data-wrangling example).
# Usage: Rscript code/data_wrang.R   (run from the coursework project root)
# Input: data/pound_hill_data.csv, data/pound_hill_meta_data.csv
# Output: results/pound_hill_long.csv
# Requires: the reshape2 package, installed once with install.packages("reshape2")
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)

# Stop with a clear message if the package or an input file is missing,
# instead of failing part-way with R's own error.
if (!requireNamespace("reshape2", quietly = TRUE)) {
  stop("Package 'reshape2' is not installed. Install it once with ",
       "install.packages(\"reshape2\").", call. = FALSE)
}

data_path <- "data/pound_hill_data.csv"
metadata_path <- "data/pound_hill_meta_data.csv"
for (path in c(data_path, metadata_path)) {
  if (!file.exists(path)) {
    stop("Input file not found: ", path,
         " (run this script from the project root)", call. = FALSE)
  }
}

# Load the data ----------------------------------------------------------
# The first rows describe the sampling design, so do not use one as a header yet.
MyData <- as.matrix(read.csv(data_path, header = FALSE))

# The metadata file does have a header and uses semicolons as separators.
MyMetaData <- read.csv(metadata_path, header = TRUE, sep = ";")

# Inspect the data -------------------------------------------------------
head(MyData)
dim(MyData)
str(MyData)
head(MyMetaData)

# Transpose so species become columns and sampled quadrats become rows.
MyData <- t(MyData) 
head(MyData)
dim(MyData)

# For this dataset, we have been told that blanks are observed absences.
# That knowledge is what allows us to record them as zero rather than NA.
MyData[MyData == ""] <- 0

# Convert the raw matrix to a data frame --------------------------------

TempData <- as.data.frame(MyData[-1, ], stringsAsFactors = FALSE)
colnames(TempData) <- MyData[1, ]
rownames(TempData) <- NULL

# Convert from wide to long form ----------------------------------------
# This script keeps the older reshape2 route because it is still common in
# ecological code. For new work, the chapter introduces tidyr::pivot_longer().
library(reshape2)

MyWrangledData <- melt(
  TempData,
  id = c("Cultivation", "Block", "Plot", "Quadrat"),
  variable.name = "Species",
  value.name = "Count"
)

MyWrangledData[, "Cultivation"] <- as.factor(MyWrangledData[, "Cultivation"])
MyWrangledData[, "Block"] <- as.factor(MyWrangledData[, "Block"])
MyWrangledData[, "Plot"] <- as.factor(MyWrangledData[, "Plot"])
MyWrangledData[, "Quadrat"] <- as.factor(MyWrangledData[, "Quadrat"])
MyWrangledData[, "Count"] <- as.integer(MyWrangledData[, "Count"])

str(MyWrangledData)
head(MyWrangledData)
dim(MyWrangledData)

# Save a derived table while leaving the raw files unchanged.
dir.create("results", showWarnings = FALSE)
write.csv(MyWrangledData, "results/pound_hill_long.csv", row.names = FALSE)

# Explore the data below this line.
