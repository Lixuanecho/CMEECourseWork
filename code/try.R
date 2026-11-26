# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: try.R
# Desc: Catching errors with try(): a sampling simulation that sometimes
#       stops with an error is repeated 15 times without halting the
#       script. The population histogram is saved to results/.
# Usage: Rscript code/try.R   (run from the root directory)
# Date: Nov 2026

doit <- function(x) {
    temp_x <- sample(x, replace = TRUE)

    if (length(unique(temp_x)) > 30) {
        print(paste(
            "Mean of this sample was:",
            as.character(mean(temp_x))
        ))
    } else {
        stop("Couldn't calculate mean: too few unique values!")
    }
}

set.seed(1345) # get the same result for illustration

popn <- rnorm(50)

# Save the histogram to results
pdf("results/try_population.pdf")
hist(popn)
invisible(dev.off())

result <- lapply(1:15, function(i) try(doit(popn), FALSE))
print(class(result)) # print() so these also show when the script is source()d
print(result)

# Repeat the exercise using a preallocated list and a for loop.
result <- vector("list", 15) 
for (i in 1:15) {
    result[[i]] <- try(doit(popn), FALSE)
}

# Check which runs were caught as errors? 
is_error <- sapply(result, inherits, what = "try-error")
cat("Runs caught as errors:", which(is_error), "\n")
cat("Successful runs:", sum(!is_error), "of", length(result), "\n")