#!/bin/bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: tiff2_png.sh
# Desc: Converts every .tif file in data/ to a .png file of the same name in
#       results/ (created if needed; a PNG of the same name is replaced).
#       Adapted from the course's current-directory starter so that, like the
#       other scripts, it runs from the project root.
# Input: data/*.tif (lowercase .tif names only). data/example_image.tif is a
#        small synthetic test image, so the script runs in a fresh clone;
#        README.md says how it was made.
# Requires: ImageMagick ('magick' in version 7, 'convert' in version 6)
# Usage: bash code/tiff2_png.sh   (run from the project root; no arguments)
# Date: Nov 2026

# The script always reads data/, so stop instead of silently ignoring arguments
if [ "$#" -ne 0 ]; then
    printf 'Usage: bash code/tiff2_png.sh   (converts data/*.tif; takes no arguments)\n' >&2
    exit 2
fi

# Use ImageMagick 7's 'magick' when it is installed, otherwise version 6's
# 'convert' (the course starter's command); stop early if neither exists
if command -v magick > /dev/null 2>&1; then
    converter=magick
elif command -v convert > /dev/null 2>&1; then
    converter=convert
else
    printf 'Error: ImageMagick is required (neither magick nor convert was found).\n' >&2
    exit 1
fi

mkdir -p results || exit 1

for filename in data/*.tif
do
    # If nothing matches, the loop gets the literal 'data/*.tif', which is not a real file
    if [[ ! -f "$filename" ]]; then
        printf 'Error: no .tif files found in data/.\n' >&2
        exit 1
    fi

    # Strip the directory and .tif extension, e.g. data/a.tif -> results/a.png
    output_file="results/$(basename "$filename" .tif).png"

    printf 'Converting %s\n' "$filename"

    if ! "$converter" "$filename" "$output_file"; then
        printf 'Error: conversion failed for %s\n' "$filename" >&2
        exit 1
    fi
done