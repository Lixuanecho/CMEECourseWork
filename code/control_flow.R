# Language: R
# Script: control_flow.R
# Des: Illustrate R control flow tools including if, else, for, and while loops
# Usage: Rscript code/control_flow.R
# Date: Nov 2026
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)

cat("== IF EXAMPLES ==\n")
a <- TRUE
if (a == TRUE) {
  cat("a is TRUE\n")
} else {
  cat("a is FALSE\n")
}

z <- runif(1)  # random number between 0 and 1
if (z <= 0.5) {
  cat("z <= 0.5\n")
} else {
  cat("z > 0.5\n")
}

cat("\n== FOR LOOP: SQUARE NUMBERS ==\n")
for (i in 1:10) {
  j <- i * i
  cat(i, "squared is", j, "\n")
}

cat("\n== FOR LOOP: ITERATE THROUGH VECTOR ==\n")
v1 <- c("a", "bc", "def")
for (x in v1) {
  cat("element:", x, "\n")
}

cat("\n== WHILE LOOP: 1^2 TO 10^2 ==\n")
i <- 0
while (i < 10) {
  i <- i + 1
  cat(i^2, "\n")
}

cat("\n== WHILE LOOP WITH SAFETY AND next/break ==\n")
i <- 0
step <- 0
while (TRUE) {
  i <- i + 1
  step <- step + 1
  
  # skip even numbers
  if (i %% 2 == 0) {
    next
  }
  
  cat("odd i:", i, "\n")
  
  # stop the loop when i >= 9
  if (i >= 9) {
    cat("Reached i >= 9, breaking loop\n")
    break
  }
  
  # safety break to avoid infinite loop
  if (step > 1000) {
    warning("Too many steps,breaking to avoid infinite loop")
    break
  }
}

cat("\nScript complete!\n")
