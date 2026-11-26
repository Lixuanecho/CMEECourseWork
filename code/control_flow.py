#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: control_flow.py
Des: Examples demonstrating the use of control flow statements such as
     conditionals, loops, and functions in Python.
Usage: python3 code/control_flow.py
Date: Oct 2026
"""

# Docstrings are considered part of the running code (normal comments are
# stripped). Hence, you can access your docstrings at run time.

__author__ = 'Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)'
__version__ = '0.0.1'

import sys

def even_or_odd(x=0):
    """
    Determine whether a number is even or odd.
    """
    # Check whether x is divisible by 2
    if x % 2 == 0:
        return f"{x} is Even!"
    return f"{x} is Odd!"


def largest_divisor_five(x=120):
    """
    Find the largest divisor of x among 2, 3, 4, and 5.
    """
    largest = 0
    if x % 5 == 0:
        largest = 5
    elif x % 4 == 0:   # 'elif' means 'else if'
        largest = 4
    elif x % 3 == 0:
        largest = 3
    elif x % 2 == 0:
        largest = 2
    else:
        # Executed when none of the above conditions are satisfied
        return f"No divisor found for {x}!"
    return f"The largest divisor of {x} is {largest}"


def is_prime(x=70):
    """
    Determine whether a number is a prime number.
    """
    # Loop through all possible divisors from 2 to x - 1
    for i in range(2, x): # ”range” returns a message of integers
        if x % i == 0:
            print(f"{x} is not a prime: {i} is a divisor")
            return False
    print(f"{x} is a prime!")
    return True


def find_all_primes(x=22):
    """
    Find all prime numbers between 2 and x (inclusive).
    """
    allprimes = []

    for i in range(2, x + 1):
        if is_prime(i):
            allprimes.append(i)
    print(f"There are {len(allprimes)} primes between 2 and {x}")
    return allprimes


def main(argv):
    """
    Main entry point of the program.
    """
    print(even_or_odd(22))
    print(even_or_odd(33))

    print(largest_divisor_five(120))
    print(largest_divisor_five(121))

    print(is_prime(60))
    print(is_prime(59))

    print(find_all_primes(100))

    return 0


if __name__ == "__main__":
    """
    Ensures that main() runs only when the script is executed directly.
    """
    status = main(sys.argv)
    sys.exit(status)