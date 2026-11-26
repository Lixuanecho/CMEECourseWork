# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: observations_practice.R
# Description: Validate and deduplicate observation counts, summarise known totals
#              and missing counts by site, and plot the known totals
# Usage: Rscript code/observations_practice.R
# Date: Nov 2026

observations <- read.csv(
    "data/bootcamp_observations.csv",
    colClasses = "character",  # Read every column as character data
    na.strings = "",           # Treat empty fields as NA
    check.names = FALSE        # Preserve the original column names
)

str(observations)
print(observations)

# Why a missing count and an observed zero must not be treated alike
#
# A count of 0 is a measurement: somebody looked and counted none. An empty
# count is the absence of a measurement: the true number could have been 0,
# 2 or 50. Recording a missing count as 0 would invent data. Totals would
# look complete when they are not, and a site where nothing was recorded
# (site C) would look the same as sites where observers really counted none
# (sites B and D). So a missing count stays NA, totals use only known counts,
# and the number of missing observations is reported beside each total.


## Validate before calculating

read_observations <- function(path) {

    data <- read.csv(
        path,
        colClasses = "character",
        na.strings = "",
        check.names = FALSE
    )

    expected_columns <- c("site", "date", "count")

    if (!identical(names(data), expected_columns)) {  # Check exact column names and order
        stop(
            basename(path),
            ": expected columns 'site', 'date', 'count' in that order; found '",
            paste(names(data), collapse = "', '"), "'.",
            call. = FALSE
        )
    }

    # CSV line of each data row (line 1 is the header). read.csv() skips
    # blank lines, so "row + 1" would point to the wrong line if there were any.
    csv_line <- which(nzchar(readLines(path, warn = FALSE)))[-1]

    if (length(csv_line) != nrow(data)) {             # e.g. a quoted field split over lines
        csv_line <- seq_len(nrow(data)) + 1
    }

    for (column in c("site", "date")) {               # Check both required text columns

        values <- data[[column]]

        invalid <- is.na(values) | trimws(values) == ""  # Find missing or blank values

        if (any(invalid)) {                           # Stop if any row contains invalid text
            row <- which(invalid)[1]

            stop(
                paste0(
                    basename(path),
                    ": CSV line ", csv_line[row],
                    ", column '", column,
                    "': missing required text"
                ),
                call. = FALSE
            )
        }
    }

    counts <- data$count

    for (i in seq_along(counts)) {                    # Check each count separately

        value <- counts[i]

        if (is.na(value)) {
            next                                      # Leave missing counts as NA
        }

        if (!grepl("^(0|[1-9][0-9]*)$", value)) {     # Validate non-negative integer text
            stop(
                paste0(
                    basename(path),
                    ": CSV line ", csv_line[i],
                    ", column 'count': found '", value,
                    "'; expected an empty field or a non-negative integer."
                ),
                call. = FALSE
            )
        }

        number <- suppressWarnings(as.integer(value))  # Convert a valid count to integer

        if (is.na(number)) {                          # Catch values outside the integer range
            stop(
                paste0(
                    basename(path),
                    ": CSV line ", csv_line[i],
                    ", column 'count': found '", value,
                    "'; integer is outside the supported range."
                ),
                call. = FALSE
            )
        }
    }

    data$count <- as.integer(data$count)

    return(data)
}


## Independent: deduplicate and summarise

summarise_observations <- function(data) {

    data <- data[!duplicated(data), ]           # Remove exact duplicate rows

    sites <- unique(data$site)                  # Get each site name once

    results <- data.frame(
        site = character(0),
        total_known = integer(0),
        missing_count = integer(0)
    )                                           # Create an empty data frame for the summary

    for (site in sites) {                       # Process each site separately

        counts <- data$count[data$site == site] # Select counts for this site

        missing_count <- sum(is.na(counts))     # Count missing observations

        if (all(is.na(counts))) {               # Check whether every count is missing
            total_known <- NA_integer_
        } else {
            total_known <- sum(counts, na.rm = TRUE)  # Sum known counts
        }

        site_result <- data.frame(
            site = site,
            total_known = total_known,
            missing_count = missing_count
        )                                       # Store the summary for the current site

        results <- rbind(results, site_result)  # Add the current site to the results
    }

    return(results)
}


# Read and summarise the ordinary observations

ordinary <- read_observations(
    "data/bootcamp_observations.csv"
)

ordinary_summary <- summarise_observations(ordinary)

print(ordinary_summary)


# Read and summarise the boundary observations

boundary <- read_observations(
    "data/bootcamp_observations_boundary.csv"
)

boundary_summary <- summarise_observations(boundary)

print(boundary_summary)


# Check the ordinary observations: A (2, 1) and B (0, 0)

stopifnot(ordinary_summary$total_known[ordinary_summary$site == "A"] == 2)
stopifnot(ordinary_summary$missing_count[ordinary_summary$site == "A"] == 1)

stopifnot(ordinary_summary$total_known[ordinary_summary$site == "B"] == 0)
stopifnot(ordinary_summary$missing_count[ordinary_summary$site == "B"] == 0)


# Check the boundary observations: C (NA, 2) and D (0, 0)

stopifnot(is.na(boundary_summary$total_known[boundary_summary$site == "C"]))
stopifnot(boundary_summary$missing_count[boundary_summary$site == "C"] == 2)

stopifnot(boundary_summary$total_known[boundary_summary$site == "D"] == 0)
stopifnot(boundary_summary$missing_count[boundary_summary$site == "D"] == 0)


# Check each whole summary. The checks above pass silently if a site is
# absent (x[site == "C"] has length 0 and stopifnot(logical(0)) passes) or
# appears twice; comparing whole tables also catches dropped or extra sites.

stopifnot(identical(ordinary_summary, data.frame(
    site = c("A", "B"), total_known = c(2L, 0L), missing_count = c(1L, 0L)
)))

stopifnot(identical(boundary_summary, data.frame(
    site = c("C", "D"), total_known = c(NA, 0L), missing_count = c(2L, 0L)
)))


# Check that invalid observations produce an error

invalid_result <- tryCatch(
    read_observations("data/bootcamp_observations_invalid.csv"),
    error = function(e) e                     # Capture the error instead of stopping the script
)

stopifnot(inherits(invalid_result, "error"))  # Check that an error occurred

stopifnot(
    grepl("found '-1'", conditionMessage(invalid_result), fixed = TRUE)
)                                             # Check that the error identifies the invalid count


## Plot known totals by site

combined_summary <- rbind(ordinary_summary, boundary_summary)

x <- seq_len(nrow(combined_summary))
known <- combined_summary$total_known
all_missing <- is.na(known)                     # Sites where every count is missing
y_top <- max(c(1, known), na.rm = TRUE) * 1.15  # Fit the largest known total

dir.create("results", showWarnings = FALSE)

pdf("results/observations_known_totals.pdf", width = 7, height = 5)

plot(
    x,
    known,
    xaxt = "n",
    xlab = "Site",
    ylab = "Known total",
    main = "Known totals by site",
    xlim = c(0.5, length(x) + 0.5),             # Leave room for labels at the edges
    ylim = c(0, y_top),
    pch = 19
)

axis(
    side = 1,
    at = x,
    labels = combined_summary$site
)

if (any(all_missing)) {                         # Mark all-missing sites rather than plot 0
    text(x[all_missing], y_top / 2, "NA\n(all missing)", col = "grey40")

    mtext(
        paste(
            "All counts missing, so total is NA for site:",
            paste(combined_summary$site[all_missing], collapse = ", ")
        ),
        side = 3,
        line = 0.3
    )
}

invisible(dev.off())

cat("All checks passed. Figure saved to results/observations_known_totals.pdf\n")