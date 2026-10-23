#!/usr/bin/env Rscript

# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: TreeHeight.R
# Des: Calculates tree heights for the 120 supplied records in data/trees.csv.
# Usage: Rscript code/TreeHeight.R      (run from the repository root)
#        source("code/TreeHeight.R")    (in R started from the repository root)
# Date: Nov 2026


input_file <- "data/trees.csv"

# call. = FALSE: show only the message, not the R call.
if (!file.exists(input_file)) {
    stop("Input file not found: data/trees.csv",
         call. = FALSE)
}

# check.names = FALSE: keep headers as written, so bad headers are rejected
# (same reading rule as get_TreeHeight.R).
trees <- read.csv(input_file,
                  check.names = FALSE,
                  stringsAsFactors = FALSE)

# Exact match, so a renamed or swapped column is not used by mistake.
required_columns <- c(
    "Species",
    "Distance.m",
    "Angle.degrees"
)

if (!identical(names(trees), required_columns)) {
    stop("Expected columns: Species, Distance.m, Angle.degrees",
         call. = FALSE)
}

# Any other count means a truncated or wrong file.
if (nrow(trees) != 120L) {
    stop("Expected 120 tree records.",
         call. = FALSE)
}

# Text entries make the column non-numeric.
if (!is.numeric(trees$Distance.m)) {
    stop("Distance.m must contain numeric values.",
         call. = FALSE)
}

# Blank cells become NA, so they fail is.finite().
# Distance must be positive; 100 m is an assumed upper limit for this survey.
# which() names the failing data rows, so the bad measurement can be found.
bad_rows <- which(!is.finite(trees$Distance.m) |
                  trees$Distance.m <= 0 |
                  trees$Distance.m > 100)

if (length(bad_rows) > 0) {
    stop("Distance.m must be finite with 0 < distance <= 100. ",
         "Invalid data row(s): ", paste(bad_rows, collapse = ", "),
         call. = FALSE)
}

if (!is.numeric(trees$Angle.degrees)) {
    stop("Angle.degrees must contain numeric values.",
         call. = FALSE)
}

# 90 degrees gives infinite height; 0 or less gives no height.
bad_rows <- which(!is.finite(trees$Angle.degrees) |
                  trees$Angle.degrees <= 0 |
                  trees$Angle.degrees >= 90)

if (length(bad_rows) > 0) {
    stop("Angle.degrees must be finite with 0 < angle < 90. ",
         "Invalid data row(s): ", paste(bad_rows, collapse = ", "),
         call. = FALSE)
}


# This function calculates heights of trees given distance of each tree
# from its base and angle to its top, using the trigonometric formula
#
# height = distance * tan(radians)
#
# ARGUMENTS
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
#
# OUTPUT
# The heights of the tree, same units as "distance"

# tan() needs radians. The function only returns the value;
# the example call below prints it, as in the practical.
TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return(height)
}

# Practical's example call; expected about 30.14.
print(TreeHeight(37, 40))

# Vectorised, so no loop is needed; each height stays in its source row.
trees$height_m <- TreeHeight(
    trees$Angle.degrees,
    trees$Distance.m
)

# results/ is Git-ignored, so it may be missing in a fresh clone.
dir.create("results",
           showWarnings = FALSE,
           recursive = TRUE)

# Written only after all checks pass, so bad input never overwrites results.
# row.names = FALSE: no extra index column.
write.csv(
    trees,
    file = "results/TreeHts.csv",
    row.names = FALSE
)

cat("Tree-height calculation completed successfully.\n")
cat("Number of records:", nrow(trees), "\n")
cat("Output: results/TreeHts.csv\n")