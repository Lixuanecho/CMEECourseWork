#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: cfexercises1.py
Description: A collection of small example functions used to practise
             conditionals, loops, and basic control flow in Python.
Usage: python3 code/cfexercises1.py
Date: Oct, 2026
"""

# Docstrings are considered part of the running code (normal comments are
# stripped). Hence, you can access your docstrings at run time using
# cfexercises1.__doc__, foo_1.__doc__, etc.

__author__ = "Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)"
__version__ = "0.0.1"

## imports ##
import sys

## functions ##

def foo_1(x):
    """
    Return the square root of x.
    """
    return x ** 0.5


def foo_2(x, y):
    """
    Return the larger value between x and y.
    """
    if x > y:
        return x
    return y


def foo_3(x, y, z):
    """
    Return the numbers x, y and z sorted in ascending order.
    """
    if x > y:
        x, y = y, x
    if x > z:
        x, z = z, x
    if y > z:
        y, z = z, y
    return [x, y, z]


def foo_4(x):
    """
    Compute factorial of x using a for loop.
    """
    result = 1
    for i in range(1, x + 1):
        result = result * i
    return result


def foo_5(x):
    """
    Compute factorial of x recursively (handles x = 0 and 1).
    """
    if x == 0 or x == 1:
        return 1
    return x * foo_5(x - 1)


def foo_6(x):
    """
    Compute factorial of x using a while loop.
    """
    facto = 1
    if x == 0:
        return 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return facto


def main(argv):
    """
    Main entry point of the program.
    """
    print("Testing foo_x functions...\n")

    # Test calls (like in control_flow.py) to show that each function works
    print("foo_1(9) =", foo_1(9))
    print("foo_2(10, 5) =", foo_2(10, 5))
    print("foo_3(9, 3, 6) =", foo_3(9, 3, 6))

    print("foo_4(5) =", foo_4(5))
    print("foo_5(5) =", foo_5(5))
    # Extra test argument as required in the instructions
    print("foo_5(10) =", foo_5(10))

    print("foo_6(5) =", foo_6(5))

    return 0

if __name__ == "__main__":
    """
    Ensures main() runs when executed directly.
    """
    status = main(sys.argv)
    sys.exit(status)