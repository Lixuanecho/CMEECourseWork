# Language: R
# Script: data_wrang_tidy.R
# Des: Wrangle the Pound Hill dataset from wide to long form using
#      tidyverse packages (dplyr, tidyr). Tidy version of data_wrang.R.
# Usage: Rscript code/data_wrang_tidy.R   (run from the project root)
# Input: data/pound_hill_data.csv, data/pound_hill_meta_data.csv
# Output: results/pound_hill_long_tidy.csv
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)

# Required packages: dplyr, tidyr
# Install them once in an ordinary R session, not inside this script:
#   install.packages(c("dplyr", "tidyr"))
# Stop with a clear message if a package or an input file is missing,
# instead of R's "there is no package" or "cannot open the connection" error.
for (package in c("dplyr", "tidyr")) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop("Package '", package, "' is not installed. Install it once with ",
         "install.packages(c(\"dplyr\", \"tidyr\")).", call. = FALSE)
  }
}

data_path <- "data/pound_hill_data.csv"
metadata_path <- "data/pound_hill_meta_data.csv"
for (path in c(data_path, metadata_path)) {
  if (!file.exists(path)) {
    stop("Input file not found: ", path,
         " (run this script from the project root)", call. = FALSE)
  }
}

# Attach the packages only after the checks. library(dplyr) prints a message
# on standard error that some functions (filter, lag, ...) are masked; this is
# expected and not an error.
library(dplyr)
library(tidyr)

# Load the data ----------------------------------------------------------
# The first rows describe the sampling design, so do not use one as a header.
# Read as a matrix so that everything stays as character for now.
MyData <- as.matrix(read.csv(data_path, header = FALSE))

# The metadata file has a header and uses semicolons as separators
# (the description field contains commas).
MyMetaData <- read.csv(metadata_path, header = TRUE, sep = ";")

# Inspect the data -------------------------------------------------------
head(MyData)
dim(MyData)
str(MyData)
head(MyMetaData)

# Transpose so species become columns and sampled quadrats become rows
MyData <- t(MyData)
head(MyData)
dim(MyData)

# For this dataset, blanks are observed absences, so record them as zero
MyData[MyData == ""] <- "0"

# Convert the raw matrix to a tibble -------------------------------------
# The first row holds the column names, not data
TempData <- as.data.frame(MyData[-1, ], stringsAsFactors = FALSE)
colnames(TempData) <- MyData[1, ]
rownames(TempData) <- NULL
TempData <- as_tibble(TempData)
glimpse(TempData)

# Convert from wide to long form -----------------------------------------
# The first four columns are identifiers; every other column is a species
MyWrangledData <- TempData %>%
  pivot_longer(
    cols      = -c(Cultivation, Block, Plot, Quadrat),
    names_to  = "Species",
    values_to = "Count"
  ) %>%
  mutate(
    Cultivation = factor(Cultivation),
    Block       = factor(Block),
    Plot        = factor(Plot),
    Quadrat     = factor(Quadrat),
    Count       = as.integer(Count)
  )

str(MyWrangledData)
head(MyWrangledData)
dim(MyWrangledData)

# Save a derived table while leaving the raw files unchanged -------------
dir.create("results", showWarnings = FALSE)
write.csv(MyWrangledData, "results/pound_hill_long_tidy.csv", row.names = FALSE)

cat("Saved results/pound_hill_long_tidy.csv with", nrow(MyWrangledData), "rows\n")