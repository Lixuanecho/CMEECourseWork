#!/bin/bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: CountLines.sh
# Desc: Counts the number of lines in a file (wc -l counts newline characters,
#       so a last line without a final newline is not counted)
# Usage: bash code/CountLines.sh <filename>   (e.g. bash code/CountLines.sh data/trees.csv)
# Date: Nov 2026

# Check argument count (messages go to standard error, output to standard output)
if [ $# -ne 1 ]; then
    echo "Usage: bash $0 <filename>" >&2
    exit 1
fi

# Check that the file exists and can be read
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found!" >&2
    exit 1
fi

if [ ! -r "$1" ]; then
    echo "Error: File '$1' is not readable!" >&2
    exit 1
fi

# Count lines. tr removes the spaces that BSD/macOS wc puts before the number.
NumLines=$(wc -l < "$1" | tr -d ' ')
echo "The file '$1' has $NumLines lines."
echo

exit 0
