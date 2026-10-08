#!/bin/bash

# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: tabtocsv.sh
# Desc: Convert a tab-delimited file to a comma-delimited file.
#       Preserve empty fields and save the output in ../results/.
# Arguments: 1 -> Path to a tab-delimited input file
# Date: Oct 2026

# Check that exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one input file is required." >&2
    echo "Usage: bash $0 <input_file>" >&2
    exit 1
fi

# Assign the input file path
input_file="$1"

# Check that the input is an existing regular file
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist or is not a regular file." >&2
    exit 1
fi

# Check that the input file is readable
if [ ! -r "$input_file" ]; then
    echo "Error: Input file '$input_file' is not readable." >&2
    exit 1
fi

# Create the results directory if it does not exist
if ! mkdir -p "../results"; then
    echo "Error: Could not create the results directory." >&2
    exit 1
fi

# Construct the output filename
filename=$(basename -- "$input_file")
output_file="../results/${filename}.csv"


echo "Creating a comma-delimited version of '$input_file' ..."

if tr '\t' ',' < "$input_file" > "$output_file"; then
    echo "Done! Output saved to '$output_file'"
else
    echo "Error: Failed to convert '$input_file'." >&2
    exit 1
fi

exit 0