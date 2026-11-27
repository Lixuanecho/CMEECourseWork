#!/bin/sh
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: csvtospace.sh
# Desc: Converts a comma-separated file to a space-separated file:
#       every comma becomes one space, so empty fields become runs of spaces.
#       The output is saved in results/ (created if needed) as <input file name>.txt.
# Usage: bash code/csvtospace.sh <input.csv>   (run from the repository root)
#        e.g. bash code/csvtospace.sh data/temperatures/1800.csv -> results/1800.csv.txt
# Date: Nov 2026

# Check the input argument
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one CSV file." >&2
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Error: File '$1' not found or unreadable." >&2
    exit 1
fi

mkdir -p results || exit 1
output="results/$(basename -- "$1").txt"   # -- : a name starting with '-' is not an option


if tr ',' ' ' < "$1" > "$output"; then
    echo "Done! Output saved to $output"
else
    echo "Error: Conversion failed" >&2
    exit 1
fi