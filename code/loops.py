#!/usr/bin/env python3
# FOR loops in Python

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: loops.py
Des: Examplify loops in python
Usage: python3 code/loops.py
Date: Nov 2026
"""

for i in range(5): 
    # Print 0,1,2,3,4
    print(i)

my_list = [0, 2, "geronimo!", 3.0, True, False]
# Ask to print every elements in my_list
for k in my_list:
    print(k)

total = 0
summands = [0, 1, 11, 111, 1111]
for s in summands:
# Calculate the sum of numbers in summands = [0, 1, 11, 111, 1111]
    total = total + s
    print(total)

# WHILE loop
z = 0
while z < 100:
    z = z + 1
    print(z)