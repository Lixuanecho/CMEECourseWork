#!/usr/bin/env python3

"""
Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: observations_practice.py
Description: Validate observation records and summarise known counts and missing records for each site
Usage: python3 code/observations_practice.py
Date: Nov 2026
"""

import csv


def load_observations(path):
    with open(path, newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


def parse_count(count_text):
    if not isinstance(count_text, str):
        raise ValueError("Count must be text")
    # An empty count means the data is missing
    if count_text == "":
        return None
    count = int(count_text)
    # Count has to be a non-negative integer
    if count < 0:
        raise ValueError("Count cannot be negative")
    return count


# Takes a list of observation records and a site to look up
# Each record has site, date and count
# The query site decides which records go into the final result
def summarise_site(rows, site):
    if not isinstance(rows, list):
        raise ValueError("Rows must be a list")

    if not isinstance(site, str) or site == "":
        raise ValueError("Site must be non-empty text")

    seen = set()
    known_total = None
    missing_count = 0

    # Check every record before doing any calculation
    # Records from other sites are checked too, bad data raises a ValueError
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError("Each row must be a dictionary")

        # Each record must have exactly site, date and count
        if set(row) != {"site", "date", "count"}:
            raise ValueError("Invalid fields")

        # All values have to be strings
        for value in row.values():
            if not isinstance(value, str):
                raise ValueError("All values must be text")

        # site and date can't be empty
        if row["site"] == "" or row["date"] == "":
            raise ValueError("Site and date cannot be empty")

        count = parse_count(row["count"])

        # Skip exact duplicates with the same site, date and count
        # Records with different dates count as different records
        # Only seen is updated, the original input stays the same
        record = (row["site"], row["date"], row["count"])
        if record in seen:
            continue
        seen.add(record)

        # Only records for the query site are counted
        if row["site"] == site:
            # An empty value is counted as a missing record
            if count is None:
                missing_count += 1
            # Add up the known counts, 0 is a known value, not missing
            else:
                if known_total is None:
                    known_total = 0
                known_total += count

    # Returns (known_total, missing_count)
    # If there is at least one known count, known_total is their sum
    # If every count for the site is missing, the total is None
    # If the input is empty or the site isn't in the data, returns (None, 0)
    return (known_total, missing_count)


# Manual check:
# Site A: the first count is 2, so the total becomes 2
# The B record gets checked but isn't added to A
# Another A record has no count, so missing_count becomes 1
# The last A record is a duplicate, so it's skipped
# So the expected result for A is (2, 1)
# Site B: the known count is 0 and nothing is missing, so it should be (0, 0)
if __name__ == "__main__":
    rows = load_observations("data/bootcamp_observations.csv")
    sites = set()

    for row in rows:
        sites.add(row["site"])

    for site in sorted(sites):
        print(f"{site}: {summarise_site(rows, site)}")