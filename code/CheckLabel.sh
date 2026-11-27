#!/bin/bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: CheckLabel.sh
# Desc: Accept exactly one tree label, oak or pine (case-sensitive).
#       Exit status: 0 = valid label, 1 = unknown label, 2 = wrong number of arguments.
# Usage: bash code/CheckLabel.sh oak|pine   (e.g. bash code/CheckLabel.sh oak)
# Date: Nov 2026

if [[ $# -ne 1 ]]; then
    printf 'Usage: %s oak|pine\n' "$0" >&2
    exit 2
fi

if [[ "$1" != "oak" && "$1" != "pine" ]]; then
    printf 'Unknown label: %s\n' "$1" >&2
    exit 1
fi

printf 'Selected species: %s\n' "$1"