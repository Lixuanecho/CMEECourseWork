#!/bin/bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: ConcatenateTwoFiles.sh
# Desc: Concatenate two files into an output file.
#       Step 1 '>' truncates/creates the output and writes file1;
#       step 2 '>>' appends file2. Rerunning therefore gives the same
#       result (no duplication), because step 1 empties the output first.
# Usage: bash code/ConcatenateTwoFiles.sh <file1> <file2> <output_file>
#        e.g. bash code/ConcatenateTwoFiles.sh data/bootcamp_observations.csv
#             data/bootcamp_observations_boundary.csv results/observations_combined.csv
# Date: Nov 2026

# Check number of arguments (messages go to standard error)
if [ $# -ne 3 ]; then
    echo "Usage: bash $0 <file1> <file2> <output_file>" >&2
    exit 1
fi

# Check that both input files exist
for f in "$1" "$2"; do
    if [ ! -f "$f" ]; then
        echo "Error: input file '$f' not found." >&2
        exit 1
    fi
done

# The output must not be one of the inputs: '>' would empty it before cat reads it.
# -ef is true when two paths refer to the same file (e.g. 'a.txt' and './a.txt').
if [ "$3" -ef "$1" ] || [ "$3" -ef "$2" ]; then
    echo "Error: output '$3' is the same file as an input. Choose a different output." >&2
    exit 1
fi

# Create the output folder if needed (results/ is Git-ignored, so a fresh clone has none)
mkdir -p "$(dirname "$3")" || exit 1

# Two deliberate steps: write the first file, then append the second
cat "$1" > "$3" || exit 1
cat "$2" >> "$3" || exit 1

echo "Merged File is"
cat "$3"