#!/bin/sh

#Check input argument
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one CSV file." >&2
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Error: File '$1' not found or unreadable." >&2
    exit 1
fi

mkdir -p ../results || exit 1
output="../results/$(basename "$1").txt"

# Convert commas to spaces
if tr ',' ' ' < "$1" > "$output"; then
    echo "Done! Output saved to $output"
else
    echo "Error:Conversion failed" >&2
    exit 1
fi
