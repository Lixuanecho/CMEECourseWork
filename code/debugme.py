#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: debugme.py
Des: Example script for debugging and demonstrating a ZeroDivisionError
Usage: python3 code/debugme.py
Date: Nov 2026
"""

__author__ = 'Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)'
__version__ = '0.0.1'

def buggyfunc(x):
    """
    Demonstrates try/except/else blocks with specific error handling.
    """
    y = x
    z = None  # Avoid UnboundLocalError when no division succeeds
    # Decrease y by 1 for x iterations
    for i in range(x):
        try:
            y = y - 1
            z = x / y
        except ZeroDivisionError:
            print(f"Division by zero is undefined; x = {x}; y = {y}")
        except Exception as e:
            print(f"This didn't work ({e}); x = {x}; y = {y}")
        else:
            print(f"OK; x = {x}; y = {y}, z = {z};")
    return z


if __name__ == "__main__":
    print("buggyfunc(20) returned:", buggyfunc(20))
    print("buggyfunc(1) returned:", buggyfunc(1))
    print("buggyfunc(0) returned:", buggyfunc(0))