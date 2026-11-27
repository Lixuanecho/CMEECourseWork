# Language: R
# Script: basic_io.R
# Des: A simple script to illustrate R input-output.
# Usage: Rscript code/basic_io.R   (run from the project root)
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)


input_file <- "data/trees.csv"
if (!file.exists(input_file)) { # clear message instead of "cannot open the connection"
  stop("Input file not found: ", input_file,
       " (run this script from the project root)", call. = FALSE)
}

dir.create("results", showWarnings = FALSE) # Create the output directory

MyData <- read.csv(input_file, header = TRUE) # import with headers

write.csv(MyData, "results/MyData.csv") # write it out as a new file

write.table(MyData[1,], file = "results/MyData.csv",
            append = TRUE, sep = ",", col.names = FALSE) # Append to it

write.csv(MyData, "results/MyData.csv", row.names = TRUE) # write row names

# Each call without append = TRUE replaces the file, so results/MyData.csv
# ends up holding only this last version: 120 rows, no header row
write.table(MyData, "results/MyData.csv", col.names = FALSE) # ignore column names