#!/usr/bin/env Rscript

# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: get_TreeHeight.R
# Des: Calculates tree heights for any CSV with the columns
#      Species, Distance.m and Angle.degrees.
# Usage: Rscript code/get_TreeHeight.R <input.csv>      (run from the repository root)
#        Rscript code/get_TreeHeight.R data/trees.csv   (example)
# Date: Nov 2026


# trailingOnly = TRUE: keep only the user's arguments.
args <- commandArgs(trailingOnly = TRUE)

# One input per run, so each output matches one input.
# call. = FALSE: show only the message, not the R call.
if (length(args) != 1) {
    stop(
        "Usage: Rscript code/get_TreeHeight.R <input.csv>",
        call. = FALSE
    )
}

input_file <- args[1]

# file.exists() is also TRUE for directories.
if (!file.exists(input_file) || dir.exists(input_file)) {
    stop(
        paste("Input file does not exist:", input_file),
        call. = FALSE
    )
}

# Report permission problems clearly, not as a read error.
if (file.access(input_file, 4) != 0) {
    stop(
        paste("Input file is not readable:", input_file),
        call. = FALSE
    )
}

# tryCatch(): one clear message for empty or malformed files.
# check.names = FALSE: keep headers as written, so bad headers are rejected.
trees <- tryCatch(
    read.csv(
        input_file,
        check.names = FALSE,
        stringsAsFactors = FALSE
    ),
    error = function(e) {
        stop(
            paste("Cannot read CSV:", conditionMessage(e)),
            call. = FALSE
        )
    }
)

# Exact match, so a renamed or swapped column is not used by mistake.
required_columns <- c(
    "Species",
    "Distance.m",
    "Angle.degrees"
)

if (!identical(names(trees), required_columns)) {
    stop(
        "CSV must contain exactly: Species, Distance.m, Angle.degrees",
        call. = FALSE
    )
}

# Any row count is allowed, but a header-only file is an error.
if (nrow(trees) == 0) {
    stop(
        "Input CSV contains no data rows.",
        call. = FALSE
    )
}

# Same checks and messages as TreeHeight.R: a deliberate copy, kept in step
# with it (the note above TreeHeight() below explains why it is not shared).
# Text entries make the column non-numeric.
if (!is.numeric(trees$Distance.m)) {
    stop(
        "Distance.m must contain numeric values.",
        call. = FALSE
    )
}

# Blank cells become NA, so they fail is.finite().
# Distance must be positive; 100 m is an assumed upper limit for this survey.
# which() names the failing data rows, so the bad measurement can be found.
bad_rows <- which(
    !is.finite(trees$Distance.m) |
    trees$Distance.m <= 0 |
    trees$Distance.m > 100
)

if (length(bad_rows) > 0) {
    stop(
        "Distance.m must be finite with 0 < distance <= 100. ",
        "Invalid data row(s): ", paste(bad_rows, collapse = ", "),
        call. = FALSE
    )
}

if (!is.numeric(trees$Angle.degrees)) {
    stop(
        "Angle.degrees must contain numeric values.",
        call. = FALSE
    )
}

# 90 degrees gives infinite height; 0 or less gives no height.
bad_rows <- which(
    !is.finite(trees$Angle.degrees) |
    trees$Angle.degrees <= 0 |
    trees$Angle.degrees >= 90
)

if (length(bad_rows) > 0) {
    stop(
        "Angle.degrees must be finite with 0 < angle < 90. ",
        "Invalid data row(s): ", paste(bad_rows, collapse = ", "),
        call. = FALSE
    )
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

# Reused from TreeHeight.R, as the practical asks. It is copied, not
# sourced, because sourcing TreeHeight.R would run that whole script and
# rewrite results/TreeHts.csv. The README compares both outputs with diff
# to check that the two copies give identical results.
TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return(height)
}

# Vectorised; each height stays in its source row.
trees$height_m <- TreeHeight(
    trees$Angle.degrees,
    trees$Distance.m
)

# Drop path and extension, as the practical requires:
# data/trees.csv -> results/trees_treeheights.csv
# Limit: inputs with the same basename (e.g. data/trees.csv and
# other/trees.csv) write to the same result file; the later run replaces it.
# The output always ends in _treeheights.csv inside results/, so it can
# never be the input file itself.
input_name <- tools::file_path_sans_ext(
    basename(input_file)
)

output_file <- file.path(
    "results",
    paste0(input_name, "_treeheights.csv")
)

# results/ is Git-ignored, so it may be missing in a fresh clone.
dir.create(
    "results",
    showWarnings = FALSE,
    recursive = TRUE
)

# Written only after all checks pass, so bad input never overwrites results.
# row.names = FALSE: no extra index column.
write.csv(
    trees,
    file = output_file,
    row.names = FALSE
)

cat("Tree heights saved to:", output_file, "\n")
