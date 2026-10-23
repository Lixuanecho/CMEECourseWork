#!/usr/bin/env Rscript

# Tree height calculation

input_file <- "data/trees.csv"

if (!file.exists(input_file)) {
    stop("Input file not found: data/trees.csv",
         call. = FALSE)
}

trees <- read.csv(input_file, stringsAsFactors = FALSE)
print(names(trees))
print(head(trees))



required_columns <- c(
    "Species",
    "Distance.m",
    "Angle.degrees"
)

if (!identical(names(trees), required_columns)) {
    stop("Expected columns: Species, Distance.m, Angle.degrees",
         call. = FALSE)
}

if (nrow(trees) != 120L) {
    stop("Expected 120 tree records.",
         call. = FALSE)
}

if (!is.numeric(trees$Distance.m) ||
    any(!is.finite(trees$Distance.m))) {

    stop("Distance.m must contain finite numeric values.",
         call. = FALSE)
}

if (any(trees$Distance.m <= 0 |
        trees$Distance.m > 100)) {

    stop("Distance.m must satisfy 0 < distance <= 100.",
         call. = FALSE)
}

if (!is.numeric(trees$Angle.degrees) ||
    any(!is.finite(trees$Angle.degrees))) {

    stop("Angle.degrees must contain finite numeric values.",
         call. = FALSE)
}

if (any(trees$Angle.degrees <= 0 |
        trees$Angle.degrees >= 90)) {

    stop("Angle.degrees must satisfy 0 < angle < 90.",
         call. = FALSE)
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

dir.create("results",
           showWarnings = FALSE,
           recursive = TRUE)
write.csv(
    trees,
    file = "results/TreeHts.csv",
    row.names = FALSE,
    quote = FALSE
)

cat("Tree-height calculation completed successfully.\n")
cat("Number of records:", nrow(trees), "\n")
cat("Output: results/TreeHts.csv\n")
