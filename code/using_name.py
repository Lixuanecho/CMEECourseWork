#!/usr/bin/env python3
# Filename: using_name.py

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: using_name.py
Des: Demonstrate the use of the special __name__ variable in Python
Usage: python3 code/using_name.py
Date: Nov 2026
"""

__author__ = 'Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)'
__version__ = '0.0.1'

if __name__ == '__main__':
    # This block runs only when the script is executed directly
    print('This program is being run by itself!')
else:
    # This block runs only when the script is imported as a module
    print('I am being imported from another script/program/module!')

print("This module's name is: " + __name__)