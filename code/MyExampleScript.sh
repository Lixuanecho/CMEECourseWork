#!/bin/sh
# Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
# Script: MyExampleScript.sh
# Desc: Print a greeting using a variable and the $USER environment variable
# Usage: bash code/MyExampleScript.sh
# Date: Nov 2026

MSG1="Hello"
MSG2=$USER
echo "$MSG1 $MSG2"
echo "Hello $USER"
echo
