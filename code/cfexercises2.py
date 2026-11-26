#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: cfexercises2.py
Des: Examples of loops and conditionals (control flow exercises) in Python
Usage: python3 code/cfexercises2.py
Date: Oct 2026
"""

#docstrings are considered part of the running code (normal comments are
#stripped). Hence, you can access your docstrings at run time.

__author__ = 'Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)'
__version__ = '0.0.1'


def hello_1(x):
    """
    Print 'hello' every time j is divisible by 3 for j in range(x).

    Parameters
    x : int
        Upper bound (non-inclusive) of the range to iterate over.
    """
    for j in range(x):
        # If j is divisible by 3, print 'hello'
        if j % 3 == 0:
            print("hello")
    # Print a blank line after finishing the loop
    print(" ")

def hello_2(x):
    """
    Print 'hello' for j in range(x) when certain modular conditions are met.

    Prints 'hello' if:
    - j % 5 == 3, or
    - j % 4 == 3

    Parameters:
    x : int
        Upper bound (non-inclusive) of the range to iterate over.
    """
    for j in range(x):
        # Check the first condition (mod 5)
        if j % 5 == 3:
            print("hello")
        # If the first condition is not met, check the second (mod 4)
        elif j % 4 == 3:
            print("hello")
    print(" ")

def hello_3(x, y):
    """
    Print 'hello' for every integer i between x (inclusive) and y (exclusive).

    Parameters:
    x : int
        Start value (inclusive).
    y : int
        End value (exclusive).
    """
    for i in range(x, y):
        # For each i in the range, print 'hello'
        print("hello")
    print(" ")

def hello_4(x):
    """
    Starting from x, repeatedly add 3 and print 'hello' until x equals 15.

    Parameters:
    x : int
        Initial value; the loop continues until x == 15.
    """
    # Continue the loop while x is not equal to 15
    while x != 15:
        print("hello")
        # Increase x by 3 each iteration
        x = x + 3
    print(" ")

def hello_5(x):
    """
    Print 'hello' while x < 100 with special behavior at specific values.

    Behavior:
    - If x == 31: print 'hello' seven times using a for-loop.
    - If x == 18: print 'hello' once.
    - x is incremented by 1 on every iteration.

    Parameters:
    x : int
        Starting value for the loop.
    """
    while x < 100:
        if x == 31:
            # When x is 31, print 'hello' seven times
            for k in range(7):
                print("hello")
        elif x == 18:
            # When x is 18, print 'hello' once
            print("hello")
        # Increment x at the end of each loop iteration
        x = x + 1
    print(" ")

def hello_6(x, y):
    """
    Print 'hello! <y>' repeatedly while x is truthy, stopping when y reaches 6.

    This demonstrates:
    - A while-loop that depends on a boolean-like variable x.
    - A break statement to exit the loop early.

    Parameters:
    x : bool
        Loop condition; if x is truthy, the while-loop can run.
    y : int
        Starting integer to be printed and incremented.
    """
    # Loop while x is truthy (e.g. x == True)
    while x:
        print("hello! " + str(y))
        # Increment y by 1 each iteration
        y += 1

        # Stop the loop when y reaches 6
        if y == 6:
            break
    print(" ")

# Example usage.
if __name__ == "__main__":
    hello_1(12)
    hello_2(12)
    hello_3(3, 17)
    hello_4(0)
    hello_5(12)
    hello_6(True, 0)