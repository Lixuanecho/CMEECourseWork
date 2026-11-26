#!/bin/bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: tiff2_png.sh
# Desc: Converts all .tif files in data/ to .png files in results/
# Usage: bash code/tiff2_png.sh   (run from the project root)
# Date: Nov 2026

# Stop early if ImageMagick's convert is not installed
if ! command -v convert > /dev/null; then
    printf 'Error: ImageMagick convert is required.\n' >&2
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

    if ! convert "$filename" "$output_file"; then
        printf 'Error: conversion failed for %s\n' "$filename" >&2
        exit 1
    fi
done