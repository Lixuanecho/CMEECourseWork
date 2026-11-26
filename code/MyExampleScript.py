#!/usr/bin/env python3
#MyExampleScript.py

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: MyExampleScript.py
Des: First script for python
Usage: python3 code/MyExampleScript.py
Date: Nov 2026
"""
def foo(x):
    """Print x squared (side effect)."""
    x *= x  # same as x = x * x
    print(x)

foo(2)
