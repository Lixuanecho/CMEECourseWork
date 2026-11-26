# Language: R
# Script: r_conditionals.R
# Des: Illustrate conditional statements inside user-defined R functions
# Usage: Rscript code/r_conditionals.R   (run from the project root)
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)

# FUNCTION 1
# This function checks whether an integer is even or odd
is.even <- function(n = 2) {
  
  # Use modulo operator %% to test divisibility by 2
  if (n %% 2 == 0) {
    return(paste(n, "is even!"))
  } else {
    return(paste(n, "is odd!"))
  }
}

# Test the function
print(is.even(6))
print(is.even(7))

# FUNCTION 2
# This function checks whether a number is a power of 2
is.power2 <- function(n = 2) {
  
  # A number is a power of 2 if log2(n) is an integer
  if (log2(n) %% 1 == 0) {
    return(paste(n, "is a power of 2!"))
  } else {
    return(paste(n, "is not a power of 2!"))
  }
}

# Test the function
print(is.power2(4))
print(is.power2(5))

# FUNCTION 3
# This function checks whether a number is prime
is.prime <- function(n) {
  
  # Handle special cases first
  if (n == 0) {
    return(paste(n, "is zero!"))
  } else if (n == 1) {
    return(paste(n, "is just a unit!"))
  } else if (n == 2) {
    return(paste(n, "is a prime!"))
  }
  
  # Generate all integers from 2 to n-1 (safe here because n >= 3)
  ints <- 2:(n - 1)
  
  # A number is prime if it is not divisible by any of these integers
  if (all(n %% ints != 0)) {
    return(paste(n, "is a prime!"))
  } else {
    return(paste(n, "is a composite!"))
  }
}

# Test the function
print(is.prime(2))   # edge case: smallest prime
print(is.prime(3))
print(is.prime(10))
print(is.prime(13))