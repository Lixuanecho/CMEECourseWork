#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: test_control_flow.py
Des: Simple example of unit testing using doctest on a control-flow function.
Usage: python3 code/test_control_flow.py      (runs the doctests silently)
       python3 -m doctest -v code/test_control_flow.py   (verbose test report)
Date: Oct 2026
"""

__author__ = 'Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import doctest  # Import the doctest module

def even_or_odd(x=0):
    """Find whether a number x is even or odd.

    >>> even_or_odd(10)
    '10 is Even!'

    >>> even_or_odd(5)
    '5 is Odd!'

    Negative numbers also work, because -2 % 2 == 0 in Python:
    >>> even_or_odd(-2)
    '-2 is Even!'
    """
    if x % 2 == 0:
        return f"{x} is Even!"
    return f"{x} is Odd!"

def main(argv):
    """
    Returns:
        The test result of function above from the terminal
    """
    print(even_or_odd(22))
    print(even_or_odd(33))
    return 0

if __name__ == "__main__":
    status = main(sys.argv)
    doctest.testmod()   # Run the embedded tests only when executed directly
    sys.exit(status)

# Alternatively, run "python3 -m doctest -v test_control_flow.py"
# if you do not want to write doctest.testmod()