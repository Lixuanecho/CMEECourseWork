#!/usr/bin/env Rscript
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: pound_hill_analysis.R
# Des: Calculate mean species richness per quadrat for each Pound Hill plot
#      and compare plots across the March, May and October cultivation treatments,
#      with a blocked analysis of the 12 plot means (treatment + block).
# Usage: Rscript code/pound_hill_analysis.R  (run from the repository root)
# Inputs: data/pound_hill_data.csv and data/pound_hill_meta_data.csv
# Outputs: results/pound_hill_plot_richness.csv and results/pound_hill_plot_richness.pdf
# Date: Nov 2026

# Treatment order for validation, sorting and the figure.
months <- c("march", "may", "october")

assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

# Draws the figure and returns the values it plotted, so step 7 can
# compare them with the saved CSV.
plot_richness_figure <- function(plot_means, path) {
  colours <- c("#477FA8", "#2C957F", "#D28A45")
  # Offset by block so the four plots of a treatment do not overlap.
  block_offsets <- c(a = -0.18, b = -0.06, c = 0.06, d = 0.18)
  # Padding leaves room for the plot labels above the points.
  y_limits <- range(plot_means$MeanRichness) + c(-1.6, 1.8)

  grDevices::pdf(path, width = 8, height = 5.5, useDingbats = FALSE)
  old_par <- graphics::par(mar = c(6.2, 5.4, 3.4, 1.1), family = "sans")
  # Close the PDF even if plotting fails, so no device is left open.
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

  # Thin grey lines join the three plots of each block (line type = block),
  # drawn first so the points sit on top. A line that peaks at May in every
  # block shows the within-block pattern that the blocked analysis tests.
  block_lty <- c(a = 1, b = 2, c = 3, d = 4)
  for (b in names(block_offsets)) {
    in_block <- plot_means[plot_means$Block == b, ]
    in_block <- in_block[match(months, in_block$Cultivation), ]
    graphics::lines(seq_along(months) + block_offsets[[b]],
                    in_block$MeanRichness, col = "#A3AAB3", lwd = 1.1,
                    lty = block_lty[[b]])
  }
  graphics::legend("topright", legend = paste("Block", names(block_lty)),
                   lty = block_lty, col = "#A3AAB3", lwd = 1.1, bty = "n",
                   cex = 0.75, text.col = "#57616D")

  drawn_points <- list()
  drawn_means <- numeric(0)
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

    # Record exactly what was drawn for the figure check.
    drawn_points[[i]] <- data.frame(Cultivation = months[i],
                                    Plot = as.character(current$Plot),
                                    y = current$MeanRichness,
                                    stringsAsFactors = FALSE)
    drawn_means[months[i]] <- treatment_mean
  }

  graphics::title(main = "Pound Hill: richness by cultivation timing",
                  adj = 0, cex.main = 1.22)
  graphics::mtext("Cultivation treatment (month)", side = 1, line = 2.7,
                  cex = 1.02)
  graphics::mtext("Mean species richness (species per quadrat)",
                  side = 2, line = 3.8, cex = 1.02)
  graphics::mtext(
    "Points = individual plots (labelled by plot ID); black lines = treatment means (4 plots each)",
    side = 1, line = 4.3, cex = 0.78, col = "#57616D"
  )
  graphics::mtext(
    "Grey lines join the three plots in the same block (line type = block a-d)",
    side = 1, line = 5.25, cex = 0.78, col = "#57616D"
  )

  invisible(list(points = do.call(rbind, drawn_points), means = drawn_means))
}

# 1. Import the supplied files. The species table is TRANSPOSED:
#    each column after the first is one quadrat; each row is a field/species.
data_path <- "data/pound_hill_data.csv"
metadata_path <- "data/pound_hill_meta_data.csv"
assert(file.exists(data_path), paste("Input file not found:", data_path))
assert(file.exists(metadata_path), paste("Metadata file not found:", metadata_path))

# Read as text: each column mixes labels and counts. na.strings keeps
# blanks as "" so only the metadata rule (step 2) decides what they mean.
raw <- utils::read.csv(data_path, header = FALSE, colClasses = "character",
                       na.strings = character(), check.names = FALSE)
# The metadata file is semicolon-separated.
metadata <- utils::read.csv(metadata_path, sep = ";", header = TRUE,
                            strip.white = TRUE, stringsAsFactors = FALSE,
                            check.names = FALSE)
names(metadata) <- trimws(names(metadata))
assert(identical(names(metadata), c("FieldName", "Description")),
       "Metadata must have FieldName and Description columns.")
metadata$FieldName <- trimws(metadata$FieldName)
metadata$Description <- trimws(metadata$Description)

# Print the imported structure so it can be inspected before analysis.
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
# Unique labels, so two species rows can never be merged by mistake.
assert(!anyNA(fields) && all(nzchar(fields)) && !anyDuplicated(fields),
       "Field/species labels must be non-empty and unique after trimming.")

species <- fields[-seq_along(required)]
# Transpose so each row is one quadrat (the sampling unit).
quadrat_wide <- t(as.matrix(raw[, -1L, drop = FALSE]))
colnames(quadrat_wide) <- fields
quadrat_info <- data.frame(
  Cultivation = trimws(quadrat_wide[, "Cultivation"]),
  Block       = trimws(quadrat_wide[, "Block"]),
  Plot        = trimws(quadrat_wide[, "Plot"]),
  Quadrat     = trimws(quadrat_wide[, "Quadrat"]),
  stringsAsFactors = FALSE
)
# Reject unexpected IDs rather than silently creating extra groups.
assert(all(nzchar(as.matrix(quadrat_info))), "Missing quadrat identifiers.")
assert(all(quadrat_info$Cultivation %in% months),
       "Unexpected cultivation treatment.")
assert(all(quadrat_info$Block %in% letters[1:4]), "Unexpected block ID.")
assert(all(grepl("^[0-9]+$", quadrat_info$Plot)), "Invalid plot ID.")
assert(!anyDuplicated(quadrat_info),
       "Repeated sampling unit: Cultivation + Block + Plot + Quadrat.")

count_text <- quadrat_wide[, species, drop = FALSE]
count_text[] <- trimws(count_text)
count_text[count_text == ""] <- "0"  # Metadata-authorised substitution.
count_values <- suppressWarnings(as.numeric(count_text))
# Counts are numbers of individuals: whole numbers, never negative.
assert(!anyNA(count_values), "Species counts contain non-numeric values.")
assert(all(is.finite(count_values) & count_values >= 0 &
             count_values == floor(count_values)),
       "Species counts must be finite, non-negative integers.")
count_matrix <- matrix(count_values, nrow = nrow(count_text),
                       ncol = ncol(count_text), dimnames = dimnames(count_text))

n_quadrats <- nrow(count_matrix)
n_species <- ncol(count_matrix)
# as.vector() reads the matrix column by column (all quadrats of species 1,
# then species 2 ...), so quadrat IDs repeat with `times`, species with `each`.
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

# Report the unequal quadrat numbers that justify averaging within plots.
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
drawn <- plot_richness_figure(plot_richness, pdf_path)
cat("Wrote:", csv_path, "and", pdf_path, "\n")

# 7. Figure check: re-read the saved CSV (the file a reader opens) and stop
#    if any plotted point or treatment mean differs from it. It runs after
#    writing because it tests the written file, not the in-memory table.
saved <- utils::read.csv(csv_path, stringsAsFactors = FALSE)
row_in_csv <- match(drawn$points$Plot, as.character(saved$Plot))
assert(nrow(saved) == 12L && nrow(drawn$points) == 12L &&
         !anyNA(row_in_csv) && !anyDuplicated(row_in_csv) &&
         identical(drawn$points$Cultivation, saved$Cultivation[row_in_csv]) &&
         isTRUE(all.equal(drawn$points$y, saved$MeanRichness[row_in_csv])),
       "Plotted points do not match the saved CSV.")
csv_means <- tapply(saved$MeanRichness, saved$Cultivation, mean)[months]
# as.numeric(): tapply() returns a 1-D array, which all.equal() treats as a
# different type from a plain vector.
assert(isTRUE(all.equal(as.numeric(csv_means), as.numeric(drawn$means[months]))),
       "Treatment-mean lines do not match the saved CSV.")

cat("Figure check passed: 12 points and 3 treatment means match the CSV.\n")
for (m in months) {
  r <- range(saved$MeanRichness[saved$Cultivation == m])
  cat(sprintf("  %-8s mean = %.2f; plot range = %.2f-%.2f\n",
              m, csv_means[[m]], r[1], r[2]))
}

# 8. Blocked comparison of the 12 plot means. Step 5 checked the design: one
#    plot of each treatment in each of four blocks. Block is therefore kept
#    in the model, so differences between blocks are not mistaken for
#    treatment effects, and the uncertainty of each treatment mean is reported.
analysis_data <- plot_richness
analysis_data$Cultivation <- factor(analysis_data$Cultivation, levels = months)
analysis_data$Block <- factor(analysis_data$Block)
blocked_fit <- stats::lm(MeanRichness ~ Cultivation + Block, data = analysis_data)
blocked_anova <- stats::anova(blocked_fit)
residual_df <- stats::df.residual(blocked_fit)
residual_ms <- blocked_anova["Residuals", "Mean Sq"]
n_blocks <- nlevels(analysis_data$Block)
# In this balanced design every treatment mean is based on one plot per block,
# so its standard error is sqrt(residual mean square / number of blocks).
se_mean <- sqrt(residual_ms / n_blocks)
se_difference <- sqrt(2 * residual_ms / n_blocks)
treatment_means <- tapply(analysis_data$MeanRichness, analysis_data$Cultivation, mean)

cat("Blocked analysis of plot means: lm(MeanRichness ~ Cultivation + Block)\n")
for (term in c("Cultivation", "Block")) {
  cat(sprintf("  %-11s F(%d, %d) = %.2f, p = %.3f\n", term,
              blocked_anova[term, "Df"], residual_df,
              blocked_anova[term, "F value"], blocked_anova[term, "Pr(>F)"]))
}
cat(sprintf("  Treatment means +/- SE (SE from the model, %d residual df):\n",
            residual_df))
for (m in months) {
  cat(sprintf("    %-8s %.2f +/- %.2f\n", m, treatment_means[[m]], se_mean))
}
cat(sprintf("  SE of a difference between two treatment means = %.2f\n",
            se_difference))

# Rank-based check of the within-block pattern: in how many blocks does each
# treatment have the highest plot mean?
first_in_block <- tapply(seq_len(nrow(analysis_data)), analysis_data$Block,
                         function(rows) as.character(
                           analysis_data$Cultivation[rows][which.max(
                             analysis_data$MeanRichness[rows])]))
friedman <- stats::friedman.test(MeanRichness ~ Cultivation | Block,
                                 data = analysis_data)
cat(sprintf("  Highest plot mean within a block: %s\n",
            paste(names(first_in_block), first_in_block, sep = " = ",
                  collapse = ", ")))
cat(sprintf("  Friedman test (treatments ranked within blocks): chi-squared = %.1f, df = %d, p = %.3f\n",
            friedman$statistic, friedman$parameter, friedman$p.value))


# Interpretation
# May cultivation had the highest typical richness (9.65 species per quadrat,
# against 7.81 for March and 7.61 for October), but plots varied widely within
# every treatment and the ranges overlap (March 6.33-10.00, May 7.40-11.60,
# October 6.40-10.25).

# The blocked analysis does not detect a treatment effect (F(2, 6) = 1.77,
# p = 0.248; May - March = 1.84, 95% CI -1.08 to 4.76), although May had the
# highest plot mean in all four blocks (exact Friedman p = 0.069).

# The figure alone cannot show that cultivation timing caused the
# differences: that would need the months to have been assigned to plots at
# random within blocks, which the metadata does not state, and four plots per
# treatment give little power to detect a difference of about two species.
