#!/bin/bash
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: variables.sh
# Desc: Demonstrates variable usage and user input
# Usage: bash code/variables.sh arg1 arg2
# Date: Nov 2026

# Special variables
echo "This script was called with $# parameters"
echo "The script's name is $0"
echo "The arguments are $*"   # "$*" joins all arguments into one string
echo "The first argument is $1"
echo "The second argument is $2"
echo

# Explicit variable
MY_VAR='some string'
echo "The current value of MY_VAR is: $MY_VAR"
echo
# -r keeps backslashes literal
read -r -p "Enter a new string (or press Enter to keep the same): " NEW_VAR

if [ -n "$NEW_VAR" ]; then
    MY_VAR="$NEW_VAR"
fi

echo
echo "Now MY_VAR is: $MY_VAR"
echo

# Read two numbers (assumed to be integers, as in the course example;
# validating arbitrary arithmetic input is outside this exercise)
read -r -p "Enter two numbers separated by space(s): " a b
if [ -z "$a" ] || [ -z "$b" ]; then
    echo "Two numbers were not entered, so the default values 0 and 0 are used."
    a=0
    b=0
fi

MY_SUM=$((a + b))
echo
echo "You entered $a and $b; their sum is: $MY_SUM"