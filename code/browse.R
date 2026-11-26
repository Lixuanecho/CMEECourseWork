# Language: R
# Script: browse.R
# Des: Demonstrate debugging with browser() in an exponential growth model
# Usage: source("code/browse.R")  (in an R console started at the project root)
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)

# This function simulates exponential population growth over a number
# of generations and uses browser() to pause execution inside the loop.
#
# ARGUMENTS:
# N0          : Initial population size (default = 1)
# r           : Intrinsic growth rate (default = 1)
# generations : Number of generations to simulate (default = 10)
#
# OUTPUT:
# A numeric vector N of length 'generations' containing the population
# size at each generation.

Exponential <- function(N0 = 1, r = 1, generations = 10) {
  
  # Create a numeric vector of length 'generations' filled with NA
  N <- rep(NA, generations)
  
  # Set the population size at the first generation
  N[1] <- N0
  
  # Loop from generation 2 to 'generations'
  for (t in 2:generations) {
    
    # Update the population size using the exponential growth equation
    N[t] <- N[t - 1] * exp(r)
    
    # Enter browser mode at each iteration
    # This allows you to inspect variables such as 't' and 'N'
    browser()
  }
  
  # Return the full time series of population sizes
  return(N)
}

# Call the Exponential function and plot the resulting trajectory
plot(
  Exponential(),
  type = "l",                         # line plot
  main = "Exponential growth",        # plot title
  xlab = "Generation",                # x-axis label
  ylab = "Population size (N)"        # y-axis label
)
