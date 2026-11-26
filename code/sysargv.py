#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: sysargv.py
Des: Demonstration of command-line arguments using sys.argv
Usage: python3 code/sysargv.py [arg1 arg2 ...]
Date: Nov 2026
"""

__author__ = 'Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
print("This is the name of the script: ", sys.argv[0])
print("Number of arguments: ", len(sys.argv))
print("The arguments are: " , str(sys.argv))
