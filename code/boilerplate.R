# Language: R
# Script: boilerplate.R
# Des: Boilerplate template for R scripts used in coursework and projects
# Usage: Rscript code/boilerplate.R
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)

# A boilerplate R script

my_function <- function(arg1, arg2) {
  
  # Statements involving arg1, arg2:
  print(paste("Argument", as.character(arg1), "is a", class(arg1))) # print arg1's type
  print(paste("Argument", as.character(arg2), "is a", class(arg2))) # print arg2's type
    
  return (c(arg1, arg2)) #this is optional, but very useful
}

my_function(1,2) #test the function
my_function("riki","Tiki") #A different test