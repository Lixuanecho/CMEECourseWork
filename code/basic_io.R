# Language: R
# Script: basic_io.R
# Des: A simple script to illustrate R input-output.
# Usage: Rscript code/basic_io.R   (run from the project root)
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)


dir.create("results", showWarnings = FALSE) # Create the output directory

MyData <- read.csv("data/trees.csv", header = TRUE) # import with headers

write.csv(MyData, "results/MyData.csv") # write it out as a new file

write.table(MyData[1,], file = "results/MyData.csv",
            append = TRUE, sep = ",", col.names = FALSE) # Append to it

write.csv(MyData, "results/MyData.csv", row.names = TRUE) # write row names

write.table(MyData, "results/MyData.csv", col.names = FALSE) # ignore column names