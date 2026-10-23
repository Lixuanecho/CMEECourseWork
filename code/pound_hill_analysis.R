#!/usr/bin/env Rscript
# Pound Hill: cultivation timing and plot-level mean species richness.
# Run from the project root: Rscript code/pound_hill_analysis.R

assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

plot_richness_figure <- function(plot_means, path) {
  months <- c("march", "may", "october")
  colours <- c("#477FA8", "#2C957F", "#D28A45")
  block_offsets <- c(a = -0.18, b = -0.06, c = 0.06, d = 0.18)
  y_limits <- range(plot_means$MeanRichness) + c(-1.6, 1.8)

  grDevices::pdf(path, width = 8, height = 5.5, useDingbats = FALSE)
  old_par <- graphics::par(mar = c(6.2, 5.4, 3.4, 1.1), family = "sans")
  on.exit({
    graphics::par(old_par)
    grDevices::dev.off()
  }, add = TRUE)

  graphics::plot(NA_real_, NA_real_, type = "n", xlim = c(0.5, 3.5),
                 ylim = y_limits, xaxs = "i", xaxt = "n", yaxt = "n",
                 xlab = "", ylab = "", bty = "n")
  graphics::abline(h = pretty(y_limits), col = "#E7EAF0", lwd = 1)
  graphics::axis(1, at = seq_along(months),
                 labels = c("March", "May", "October"), cex.axis = 1.1)
  graphics::axis(2, at = pretty(y_limits), las = 1, cex.axis = 0.95)
  graphics::box(bty = "l", col = "#9299A2")

  for (i in seq_along(months)) {
    current <- plot_means[plot_means$Cultivation == months[i], ]
    x <- i + unname(block_offsets[as.character(current$Block)])
    treatment_mean <- mean(current$MeanRichness)

    # Line is the equally weighted mean of the four independent plots.
    graphics::segments(i - 0.28, treatment_mean, i + 0.28,
                       treatment_mean, lwd = 3, col = "#303840")
    graphics::points(x, current$MeanRichness, pch = 21, cex = 1.55,
                     bg = colours[i], col = "white", lwd = 1.2)
    graphics::text(x, current$MeanRichness,
                   labels = paste0("P", as.character(current$Plot)),
                   pos = 3, offset = 0.45, cex = 0.73, col = "#303840")
  }

  graphics::title(main = "Pound Hill: richness by cultivation timing",
                  adj = 0, cex.main = 1.22)
  graphics::mtext("Cultivation treatment (month)", side = 1, line = 2.7,
                  cex = 1.02)
  graphics::mtext("Mean species richness (species per quadrat)",
                  side = 2, line = 3.8, cex = 1.02)
  graphics::mtext(
    "Points = individual plots (labelled by plot ID); lines = treatment means (4 plots each)",
    side = 1, line = 4.65, cex = 0.78, col = "#57616D"
  )
}

# 1. Import the supplied files. The species table is TRANSPOSED:
#    each column after the first is one quadrat; each row is a field/species.
data_path <- "data/pound_hill_data.csv"
metadata_path <- "data/pound_hill_meta_data.csv"
assert(file.exists(data_path), paste("Input file not found:", data_path))
assert(file.exists(metadata_path), paste("Metadata file not found:", metadata_path))

raw <- utils::read.csv(data_path, header = FALSE, colClasses = "character",
                       na.strings = character(), check.names = FALSE)
metadata <- utils::read.csv(metadata_path, sep = ";", header = TRUE,
                            strip.white = TRUE, stringsAsFactors = FALSE,
                            check.names = FALSE)
names(metadata) <- trimws(names(metadata))
assert(identical(names(metadata), c("FieldName", "Description")),
       "Metadata must have FieldName and Description columns.")
metadata$FieldName <- trimws(metadata$FieldName)
metadata$Description <- trimws(metadata$Description)

cat("Raw dimensions:", nrow(raw), "rows x", ncol(raw), "columns\n")
cat("Raw column types:", paste(unique(vapply(raw, typeof, character(1))),
                                  collapse = ", "), "\n")
cat("Raw preview (first six columns):\n")
print(utils::head(raw[, seq_len(min(6L, ncol(raw))), drop = FALSE]))
cat("Metadata dimensions:", nrow(metadata), "rows x", ncol(metadata),
    "columns; types:", paste(vapply(metadata, typeof, character(1)),
                              collapse = ", "), "\n")
print(utils::head(metadata))


# 2. The supplied metadata explicitly defines blank SpeciesCount as
#    observed absence. This is dataset-specific: blanks are NOT generally zero.
blank_rule <- metadata$Description[metadata$FieldName == "BlankSpeciesCount"]
assert(length(blank_rule) == 1L &&
         grepl("observed absence", blank_rule, ignore.case = TRUE) &&
         grepl("zero", blank_rule, ignore.case = TRUE),
       "Metadata does not establish that blank species counts mean zero.")

fields <- trimws(raw[[1L]])
required <- c("Cultivation", "Block", "Plot", "Quadrat")
assert(nrow(raw) > length(required) && ncol(raw) > 1L,
       "The data must contain quadrats and species rows.")
assert(identical(fields[seq_along(required)], required),
       "The first four data rows must be Cultivation, Block, Plot, Quadrat.")
assert(!anyNA(fields) && all(nzchar(fields)) && !anyDuplicated(fields),
       "Field/species labels must be non-empty and unique after trimming.")

species <- fields[-seq_along(required)]
quadrat_wide <- t(as.matrix(raw[, -1L, drop = FALSE]))
colnames(quadrat_wide) <- fields
quadrat_info <- data.frame(
  Cultivation = trimws(quadrat_wide[, "Cultivation"]),
  Block       = trimws(quadrat_wide[, "Block"]),
  Plot        = trimws(quadrat_wide[, "Plot"]),
  Quadrat     = trimws(quadrat_wide[, "Quadrat"]),
  stringsAsFactors = FALSE
)
assert(all(nzchar(as.matrix(quadrat_info))), "Missing quadrat identifiers.")
assert(all(quadrat_info$Cultivation %in% c("march", "may", "october")),
       "Unexpected cultivation treatment.")
assert(all(quadrat_info$Block %in% letters[1:4]), "Unexpected block ID.")
assert(all(grepl("^[0-9]+$", quadrat_info$Plot)), "Invalid plot ID.")
assert(!anyDuplicated(quadrat_info),
       "Repeated sampling unit: Cultivation + Block + Plot + Quadrat.")

count_text <- quadrat_wide[, species, drop = FALSE]
count_text[] <- trimws(count_text)
count_text[count_text == ""] <- "0"  # Metadata-authorised substitution.
count_values <- suppressWarnings(as.numeric(count_text))
assert(!anyNA(count_values), "Species counts contain non-numeric values.")
assert(all(is.finite(count_values) & count_values >= 0 &
             count_values == floor(count_values)),
       "Species counts must be finite, non-negative integers.")
count_matrix <- matrix(count_values, nrow = nrow(count_text),
                       ncol = ncol(count_text), dimnames = dimnames(count_text))

n_quadrats <- nrow(count_matrix)
n_species <- ncol(count_matrix)
long_counts <- data.frame(
  Cultivation = rep(quadrat_info$Cultivation, times = n_species),
  Block       = rep(quadrat_info$Block, times = n_species),
  Plot        = rep(quadrat_info$Plot, times = n_species),
  Quadrat     = rep(quadrat_info$Quadrat, times = n_species),
  Species     = rep(species, each = n_quadrats),
  Count       = as.vector(count_matrix),
  stringsAsFactors = FALSE
)

# 3. Every species-by-quadrat combination must occur once; Q1 alone is
#    not a unique sample. No pooled quadrat counts are used as replicates.
quadrat_key <- interaction(long_counts[required], drop = TRUE)
assert(nrow(long_counts) == n_species * n_quadrats &&
         length(unique(long_counts$Species)) == n_species &&
         length(unique(quadrat_key)) == n_quadrats &&
         all(table(quadrat_key) == n_species),
       "Long-form species/quadrat counts are incomplete or duplicated.")
cat(sprintf("Validated: %d species, %d quadrats, %d long-form counts.\n",
            n_species, n_quadrats, nrow(long_counts)))

# 4. Species RICHNESS = number of species with Count > 0 per quadrat;
#    never sum the numbers of individual plants.
long_counts$Present <- as.integer(long_counts$Count > 0)
quadrat_richness <- stats::aggregate(
  Present ~ Cultivation + Block + Plot + Quadrat,
  data = long_counts, FUN = sum
)
names(quadrat_richness)[names(quadrat_richness) == "Present"] <- "Richness"
assert(nrow(quadrat_richness) == n_quadrats &&
         all(quadrat_richness$Richness >= 0 &
               quadrat_richness$Richness <= n_species),
       "Invalid quadrat-level richness summary.")

# 5. Average quadrats WITHIN each plot first. Plots, not quadrats,
#    are the treatment-level replicates (unequal quadrat sample sizes).
plot_richness <- stats::aggregate(
  Richness ~ Cultivation + Block + Plot,
  data = quadrat_richness, FUN = mean
)
names(plot_richness)[names(plot_richness) == "Richness"] <- "MeanRichness"
months <- c("march", "may", "october")
plot_richness <- plot_richness[order(
  match(plot_richness$Cultivation, months),
  plot_richness$Block, as.integer(as.character(plot_richness$Plot))
), ]
row.names(plot_richness) <- NULL

# Exactly one plot per treatment in each of the four blocks: 12 plots.
block_design <- table(plot_richness$Cultivation, plot_richness$Block)
assert(nrow(plot_richness) == 12L &&
         identical(dim(block_design), c(3L, 4L)) &&
         all(block_design == 1L),
       "Expected 12 unique plots: one per cultivation in each block.")

n_per_plot <- stats::aggregate(
  Quadrat ~ Cultivation + Block + Plot, data = quadrat_richness,
  FUN = length
)
cat("Quadrats per plot: min =", min(n_per_plot$Quadrat),
    "; max =", max(n_per_plot$Quadrat), "\n")
cat("Plot-level richness:\n")
print(plot_richness, row.names = FALSE)

# 6. Recreate both outputs from scratch on every successful run.
dir.create("results", showWarnings = FALSE, recursive = TRUE)
csv_path <- "results/pound_hill_plot_richness.csv"
pdf_path <- "results/pound_hill_plot_richness.pdf"
utils::write.csv(plot_richness, csv_path, row.names = FALSE)
plot_richness_figure(plot_richness, pdf_path)
cat("Wrote:", csv_path, "and", pdf_path, "\n")

# Interpretation
# May cultivation had the highest mean plot-level species richness
# (9.65 species per quadrat), compared with March (7.81) and October (7.61).

# Richness varied among plots within each treatment, with overlapping
# ranges (March: 6.33–10.00; May: 7.40–11.60; October: 6.40–10.25).

# These descriptive patterns do not establish causation; interpreting
# treatment effects requires evidence of randomisation, baseline
# comparability, and control of block-level environmental variation.