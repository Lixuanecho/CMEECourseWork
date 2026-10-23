#!/usr/bin/env Rscript

# Calculate tree heights from a CSV supplied as a command-line argument.
# Run from the project root:
# Rscript code/get_TreeHeight.R data/trees.csv


args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
    stop(
        "Usage: Rscript code/get_TreeHeight.R <input.csv>",
        call. = FALSE
    )
}

input_file <- args[1]


if (!file.exists(input_file) || dir.exists(input_file)) {
    stop(
        paste("Input file does not exist:", input_file),
        call. = FALSE
    )
}

if (file.access(input_file, 4) != 0) {
    stop(
        paste("Input file is not readable:", input_file),
        call. = FALSE
    )
}


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


if (nrow(trees) == 0) {
    stop(
        "Input CSV contains no data rows.",
        call. = FALSE
    )
}


if (
    !is.numeric(trees$Distance.m) ||
    any(!is.finite(trees$Distance.m)) ||
    any(trees$Distance.m <= 0 | trees$Distance.m > 100)
) {
    stop(
        "Distance.m must contain finite numbers in (0, 100].",
        call. = FALSE
    )
}


if (
    !is.numeric(trees$Angle.degrees) ||
    any(!is.finite(trees$Angle.degrees)) ||
    any(trees$Angle.degrees <= 0 | trees$Angle.degrees >= 90)
) {
    stop(
        "Angle.degrees must contain finite numbers in (0, 90).",
        call. = FALSE
    )
}

TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return(height)
}


trees$height_m <- TreeHeight(
    trees$Angle.degrees,
    trees$Distance.m
)



input_name <- tools::file_path_sans_ext(
    basename(input_file)
)

output_file <- file.path(
    "results",
    paste0(input_name, "_treeheights.csv")
)


dir.create(
    "results",
    showWarnings = FALSE,
    recursive = TRUE
)

write.csv(
    trees,
    file = output_file,
    row.names = FALSE
)

cat("Tree heights saved to:", output_file, "\n")