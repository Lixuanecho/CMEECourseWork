#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: test_observations_practice.py
Description: Check parse_count and summarise_site with normal, boundary, failure and unchanged-input cases
Usage: python3 -B code/test_observations_practice.py
       (prints one line when every check passes; do not use python3 -O)
Date: Nov 2026
"""

import os
import tempfile

from observations_practice import load_observations, parse_count, summarise_site

# These checks are plain assert statements, as in the course exercise.
# python3 -O removes assert statements, so the script would "pass" without
# checking anything; refuse to run in that case.
if not __debug__:
    raise SystemExit("Error: run these tests without -O; it disables assert statements.")

# The file checks below use paths from the project root
for data_file in ("data/bootcamp_observations.csv",
                  "data/bootcamp_observations_boundary.csv",
                  "data/bootcamp_observations_invalid.csv"):
    if not os.path.isfile(data_file):
        raise SystemExit(f"Error: {data_file} not found; run the tests from the project root.")


# Checks for parse_count
# Normal text such as "2" is turned into the integer 2
assert parse_count("2") == 2

# "0" is a real observation, so it should give 0
assert parse_count("0") == 0

# Empty text means the count is missing, so the result is None
assert parse_count("") is None

# Negative numbers, words and non-text input all have to raise ValueError
# The second line follows the rule shared with observations_practice.R:
# int() accepts a sign, spaces, leading zeros, "_" and non-ASCII digits,
# but these are not plain non-negative integer text, so they are rejected too
for bad_count in ["-1", "many", 2,
                  "+2", " 2", "2 ", "02", "1_000", "2.0", "٢"]:
    try:
        parse_count(bad_count)
    except ValueError:
        pass
    else:
        raise AssertionError(f"Invalid count accepted: {bad_count!r}")


# Stage 1: valid records with no missing counts and no duplicates
# A has 2 + 3 = 5 and the B record is ignored
unique_rows = [
    {"site": "A", "date": "2026-10-01", "count": "2"},
    {"site": "A", "date": "2026-10-02", "count": "3"},
    {"site": "B", "date": "2026-10-01", "count": "9"},
]
assert summarise_site(unique_rows, "A") == (5, 0)

# Stage 2: missing counts and zeros
# C has only missing counts, so the total is None and missing is 2
missing_rows = [
    {"site": "C", "date": "2026-10-01", "count": ""},
    {"site": "C", "date": "2026-10-02", "count": ""},
]
# D has a known count of 0, which is not the same as missing
zero_rows = [{"site": "D", "date": "2026-10-01", "count": "0"}]
assert summarise_site(missing_rows, "C") == (None, 2)
assert summarise_site(zero_rows, "D") == (0, 0)
# An empty list and a site that isn't there both give (None, 0)
assert summarise_site([], "A") == (None, 0)
assert summarise_site(unique_rows, "Z") == (None, 0)

# Stage 3: exact duplicates
# A repeated non-zero record would make the total 7 if it were not skipped
assert summarise_site(unique_rows + [unique_rows[0]], "A") == (5, 0)
# A repeated missing record would make missing 3 if it were not skipped
assert summarise_site(missing_rows + [missing_rows[0]], "C") == (None, 2)


# Checks with the data files
# Ordinary file: A has 2, one missing record and one duplicate, B has a 0
rows = load_observations("data/bootcamp_observations.csv")
assert summarise_site(rows, "A") == (2, 1)
assert summarise_site(rows, "B") == (0, 0)

# Boundary file: C is all missing, D is a repeated 0
boundary_rows = load_observations("data/bootcamp_observations_boundary.csv")
assert summarise_site(boundary_rows, "C") == (None, 2)
assert summarise_site(boundary_rows, "D") == (0, 0)
# A site that isn't in the ordinary file
assert summarise_site(rows, "Z") == (None, 0)


# Failure checks
# The call should raise ValueError, if it doesn't the check fails
# Other kinds of errors are not caught, so they still show up
def expect_summary_error(rows, site="A"):
    try:
        summarise_site(rows, site)
    except ValueError:
        pass
    else:
        raise AssertionError("Expected ValueError, but the call succeeded")


# Each invalid row is tested on its own
# The B row should still raise an error when the query site is A
invalid_rows = load_observations("data/bootcamp_observations_invalid.csv")
for invalid_row in invalid_rows:
    expect_summary_error([invalid_row])

# Missing date field
expect_summary_error([{"site": "A", "count": "2"}])
# Extra field
expect_summary_error([{"site": "A", "date": "2026-10-01", "count": "2", "extra": "x"}])
# Empty site
expect_summary_error([{"site": "", "date": "2026-10-01", "count": "2"}])
# Empty date
expect_summary_error([{"site": "A", "date": "", "count": "2"}])
# Count is an integer instead of text
expect_summary_error([{"site": "A", "date": "2026-10-01", "count": 2}])
# Row is not a dictionary
expect_summary_error(["not a row dictionary"])
# Rows is not a list
expect_summary_error(None)
# Query site is empty or not text
expect_summary_error(rows, "")
expect_summary_error(rows, 2)
# Site or date made only of spaces (also rejected by the R version)
expect_summary_error([{"site": " ", "date": "2026-10-01", "count": "2"}])
expect_summary_error([{"site": "A", "date": "  ", "count": "2"}])
# "2" and "02" for the same site and date: "02" is not valid count text,
# so it is an error rather than a second observation (total 4)
expect_summary_error([
    {"site": "A", "date": "2026-10-01", "count": "2"},
    {"site": "A", "date": "2026-10-01", "count": "02"},
])


# Checks for load_observations
# A missing file and a file with the wrong columns stop with a clear error
try:
    load_observations("data/no_such_file.csv")
except FileNotFoundError as error:
    assert "Input file not found" in str(error)
else:
    raise AssertionError("A missing file was accepted")

with tempfile.TemporaryDirectory() as folder:
    wrong_columns = os.path.join(folder, "wrong_columns.csv")
    with open(wrong_columns, "w", encoding="utf-8") as stream:
        stream.write("site,count,date\nA,2,2026-10-01\n")
    try:
        load_observations(wrong_columns)
    except ValueError as error:
        assert "expected columns" in str(error)
    else:
        raise AssertionError("A file with the wrong columns was accepted")


# The input should stay the same after the call
# Each dictionary is copied, so a changed field would also be caught
original_rows = [row.copy() for row in rows]
summarise_site(rows, "A")
assert rows == original_rows


# My own example, worked out by hand first
# E: 4 + 6 = 10, one missing count, the second 2026-11-01 record is a duplicate
# The F record is checked but not added to E
new_rows = [
    {"site": "E", "date": "2026-11-01", "count": "4"},
    {"site": "E", "date": "2026-11-02", "count": ""},
    {"site": "E", "date": "2026-11-03", "count": "6"},
    {"site": "E", "date": "2026-11-01", "count": "4"},
    {"site": "F", "date": "2026-11-01", "count": "9"},
]
assert summarise_site(new_rows, "E") == (10, 1)


# Every assert above passed (a failure would have stopped the script)
print("All observation checks passed.")
