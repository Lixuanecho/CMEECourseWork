# Language: R
# Script: next.R
# Des: Illustrate the use of the next statement in a for loop
# Usage: Rscript code/next.R
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)

# Loop over the integers from 1 to 10
for (i in 1:10) {

  # Check if i is an even number using the modulo operator
  if ((i %% 2) == 0) {
    
    # Skip the rest of the loop and move to the next iteration
    next
  }

  # If the number is not even (i.e., it is odd), print it
  print(i)
}