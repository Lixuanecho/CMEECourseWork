#!/bin/bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: tiff2_png.sh
# Desc: Converts every .tif file in data/ to a .png file of the same name in
#       results/ (created if needed; a PNG of the same name is replaced).
#       Adapted from the course's current-directory starter so that, like the
#       other scripts, it runs from the project root.
# Input: data/*.tif. The repository ships no TIFF images on purpose; README.md
#        shows how to test the script on generated images in a temporary copy,
#        so nothing is added to data/.
# Requires: ImageMagick ('magick' in version 7, 'convert' in version 6)
# Usage: bash code/tiff2_png.sh   (run from the project root)
# Date: Nov 2026

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
        printf 'Error: no .tif files found in data/. The repository ships none; see README.md to test this script.\n' >&2
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
