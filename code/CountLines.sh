#!/bin/bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: CountLines.sh
# Desc: Counts the number of lines in a file
# Usage: bash code/CountLines.sh <filename>
# Date: Nov 2026

# Check argument count
if [ $# -ne 1 ]; then
    echo "Usage: bash $0 <filename>"
    exit 1
fi

# Check file existence
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found!"
    exit 1
fi

# Count lines
NumLines=$(wc -l < "$1")
echo "The file '$1' has $NumLines lines."
echo

exit 0