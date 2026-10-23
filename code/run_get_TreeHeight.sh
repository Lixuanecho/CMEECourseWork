#!/usr/bin/env bash

# Stop the script if a command fails
set -e

# Run the generalized tree-height calculation
Rscript code/get_TreeHeight.R data/trees.csv