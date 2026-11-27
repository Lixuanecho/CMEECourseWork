#!/bin/sh

# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: tabtocsv.sh
# Desc: Convert a tab-delimited file to a comma-delimited file in results/.
#       Each tab becomes one comma, so empty fields are kept (4<TAB><TAB>6 -> 4,,6).
# Arguments: 1 -> path to one tab-delimited input file
# Usage: bash code/tabtocsv.sh <input.tsv>   (run from the repository root)
#        e.g. bash code/tabtocsv.sh data/tab-example.tsv -> results/tab-example.tsv.csv
# Date: Nov 2026

# One input per run, so each output comes from one file (extra arguments
# would otherwise be ignored without a warning)
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one input file is required." >&2
    echo "Usage: bash $0 <input_file>" >&2
    exit 1
fi

input_file="$1"

# Check the input first, for one clear message instead of an error from tr;
# -f fails for a missing path or a directory, -r for a file we may not read
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist or is not a regular file." >&2
    exit 1
fi

if [ ! -r "$input_file" ]; then
    echo "Error: Input file '$input_file' is not readable." >&2
    exit 1
fi

# results/ is Git-ignored, so a fresh clone has none; -p also succeeds if it exists
if ! mkdir -p "results"; then
    echo "Error: Could not create the results directory." >&2
    exit 1
fi

# basename keeps only the file name, so the output always goes to results/;
# "--" stops a name that starts with "-" from being read as an option.
# Adding .csv to the full name shows which file the output came from and
# means it can never overwrite the input.
filename=$(basename -- "$input_file")
output_file="results/${filename}.csv"


echo "Creating a comma-delimited version of '$input_file' ..."

# ">" replaces an earlier output, so a rerun gives the same file, not extra rows.
# "Done!" is printed only if tr succeeded; errors go to stderr with exit status 1.
if tr '\t' ',' < "$input_file" > "$output_file"; then
    echo "Done! Output saved to '$output_file'"
else
    echo "Error: Failed to convert '$input_file'." >&2
    exit 1
fi

exit 0