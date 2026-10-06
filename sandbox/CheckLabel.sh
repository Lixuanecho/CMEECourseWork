#!/bin/bash

if [[ $# -ne 1 ]]; then
    printf 'Usage: %s oak|pine\n' "$0" >&2
    exit 2
fi

if [[ "$1" != "oak" && "$1" != "pine" ]]; then
    printf 'Unknown label: %s\n' "$1" >&2
    exit 1
fi

printf 'Selected species: %s\n' "$1"
