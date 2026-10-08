#!/usr/bin/env python3

"""Some functions exemplifying the use of control statement"""
__author__ = 'Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)'

import sys
import doctest

def even_or_odd(x=0):
    """Find whether a number x is even or odd.

    >>> even_or_odd(10)
    '10 is Even!'

    >>> even_or_odd(5)
    '5 is Odd!'

    in case of negative numbers:
    >>> even_or_odd(-2)
    '-2 is Even!'

    """
    #Define function to be tested
    if x % 2 == 0:
        return f"{x} is Even!"
    return f"{x} is Odd!"

def main(argv):
    print(even_or_odd(22))
    print(even_or_odd(33))
    return 0

if (__name__ == "__main__"):
    status = main(sys.argv)

doctest.testmod()