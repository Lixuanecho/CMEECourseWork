#!/usr/bin/env bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: run_get_TreeHeight.sh
# Desc: Tests get_TreeHeight.R from the shell. It runs the R script with
#       Rscript on the example file data/trees.csv (source() cannot pass a
#       command-line argument), stops if that fails, and then checks that the
#       result file was written.
# Usage: bash code/run_get_TreeHeight.sh   (run from the repository root)
# Input: data/trees.csv   Output: results/trees_treeheights.csv
# Date: Oct 2026

# Stop the script if a command fails
set -e

input_file="data/trees.csv"
output_file="results/trees_treeheights.csv"

if ! command -v Rscript > /dev/null 2>&1; then
    echo "Error: Rscript was not found. Install R to run this test." >&2
    exit 1
fi

# Run the generalised tree-height calculation (set -e stops here on an error)
Rscript code/get_TreeHeight.R "$input_file"

# Check the result: it must exist and not be empty
if [ ! -s "$output_file" ]; then
    echo "Error: $output_file was not created." >&2
    exit 1
fi

# Subtract the header line to report the number of data rows
echo "Checked: $output_file has $(( $(wc -l < "$output_file") - 1 )) data rows."
