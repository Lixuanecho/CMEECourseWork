#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: boilerplate.py
Desc:   Template for an import-safe Python program: definitions, a main()
        function that coordinates the program, and the main guard, so that
        importing the module runs nothing. Prints "This is a boilerplate".
Usage:  python3 code/boilerplate.py   (run from the repository root)
Date:   Nov 2026
"""

__author__ = 'Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)'
__version__ = '0.0.1'

## imports ##
import sys  # sys.argv holds the command-line arguments; sys.exit() sets the exit status

## functions ##
def main(argv):
    """Run the program's main task and return its exit status (0 = success).

    argv is the list of command-line arguments; this template does not use it.
    """
    print('This is a boilerplate')
    return 0

# Code under the guard runs only when the file is run directly, not when it is
# imported; sys.exit() passes main()'s return value to the shell
if __name__ == "__main__":
    status = main(sys.argv)
    sys.exit(status)