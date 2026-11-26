# Language: R
# Script: break.R
# Des: Illustrate the use of the break statement in a while loop
# Usage: Rscript code/break.R
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)

# Initialize the counter variable
i <- 0

# Start an infinite while loop
while (i < Inf) {

  # Check whether i has reached 10
  if (i == 10) {

    # Break out of the loop when i equals 10
    break

  } else {

    # Print the current value of i
    cat("i equals", i, "\n")

    # Update i by increasing its value by 1
    i <- i + 1
  }
}
