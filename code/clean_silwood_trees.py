#!/usr/bin/env python3
"""Validate and clean the synthetic Silwood tree survey.

Author: Lixuan Zhu (lixuan.zhu26@imperial.ac.uk)
Script: clean_silwood_trees.py
Desc:   Reads data/silwood_trees_raw.csv, checks every record against the rules
        in data/silwood_trees_metadata.md and writes three files to results/
        (created if needed, replaced on every run):
          silwood_trees_clean.csv  accepted records in canonical form
          silwood_tree_issues.csv  rejected records with their reasons
          oak_species_counts.csv   accepted Quercus records per species
        Values are never corrected or inferred: a record that breaks a rule
        is rejected with every reason that applies, in the metadata's order.
Usage:  python3 code/clean_silwood_trees.py   (run from the repository root)
        Importing the module reads and writes nothing; the tests import it.
Date:   Oct 2026 (revised Nov 2026)
"""

from __future__ import annotations

import csv
import math
import re
import sys
from decimal import Decimal
from pathlib import Path
from typing import Iterable


PROJECT_ROOT = Path(__file__).resolve().parents[1]
INPUT_PATH = PROJECT_ROOT / "data" / "silwood_trees_raw.csv"
RESULTS_DIR = PROJECT_ROOT / "results"

INPUT_FIELDS = [
    "record_id",
    "location",
    "genus",
    "species",
    "distance_m",
    "angle_degrees",
]
ISSUE_FIELDS = ["source_row", "record_id", "reasons"]
OAK_COUNT_FIELDS = ["species", "count"]

# Permitted values from the metadata. They are built once, when the module is
# imported, rather than on every call to validate_record(). Each lookup maps a
# case-folded spelling to the canonical spelling that is written out.
LOCATIONS = ("Silwood Bottom", "Nash's Field", "Manor House", "Reactor Wood")
TAXA = {
    "Quercus": ("robur", "petraea"),
    "Acer": ("pseudoplatanus",),
    "Betula": ("pendula",),
    "Fagus": ("sylvatica",),
    "Fraxinus": ("excelsior",),
}
LOCATION_LOOKUP = {name.casefold(): name for name in LOCATIONS}
GENUS_LOOKUP = {name.casefold(): name for name in TAXA}
SPECIES_LOOKUP = {
    species.casefold(): species
    for species_names in TAXA.values()
    for species in species_names
}

# "ST" followed by exactly three ASCII digits ([0-9], unlike \d, excludes
# other Unicode digits).
RECORD_ID_PATTERN = re.compile(r"ST[0-9]{3}")

# Plain ASCII number text: an optional sign, digits with an optional decimal
# part, and an optional exponent (12, 12.5, .5, -2, 1e2). float() on its own
# would also accept "1_0", non-ASCII digits and words such as "nan" and "inf".
NUMBER_PATTERN = re.compile(
    r"[+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?"
)


def load_records(path: Path = INPUT_PATH) -> list[tuple[int, dict[str, str]]]:
    """Read the survey, check its column names and number its records.

    Returns (line number, row) pairs, where the header is line 1. The line
    number comes from reader.line_num because csv.DictReader skips blank
    lines: counting rows instead would give every record after a blank line
    the wrong source_row. (For a record whose quoted field spans several
    lines, line_num is the record's last line.)
    """
    if not path.is_file():
        shown = path.relative_to(PROJECT_ROOT) if path.is_relative_to(PROJECT_ROOT) else path
        raise FileNotFoundError(f"Input file not found: {shown}")
    with path.open(newline="", encoding="utf-8") as source:
        reader = csv.DictReader(source)
        if reader.fieldnames != INPUT_FIELDS:
            raise ValueError(
                f"Expected columns {INPUT_FIELDS}, found {reader.fieldnames}"
            )
        # reader.line_num is read after each row, so it is that row's line
        return [(reader.line_num, row) for row in reader]


def decimal_text(number: float) -> str:
    """Write a number as decimal text, never in exponent notation.

    repr() gives the shortest text that reads back as the same number, but it
    switches to exponent notation for small values (1e-07), which is not the
    "valid decimal text" the metadata asks for. Decimal keeps that exact
    value, and the "f" format writes it as 0.0000001.
    """
    text = repr(number)
    if "e" in text or "E" in text:
        text = format(Decimal(text), "f")
    return text


def validate_record(
    row: dict[str, str],
    accepted_ids: set[str],
) -> tuple[dict[str, str] | None, list[str]]:
    """Clean one record, or return the reasons it cannot be used.

    accepted_ids holds the identifiers of records accepted so far; it is read
    but not changed here, because only an accepted record may reserve an
    identifier (process_records() adds it).
    """
    # Remove surrounding whitespace; a missing field (None) becomes "".
    clean = {
        field: (row.get(field) or "").strip()
        for field in INPUT_FIELDS
    }
    reasons = []

    record_id = clean["record_id"]
    if not record_id:
        reasons.append("missing record_id")
    elif RECORD_ID_PATTERN.fullmatch(record_id) is None:
        reasons.append("invalid record_id")
    elif record_id in accepted_ids:
        reasons.append("duplicate record_id")

    # Text fields are matched without regard to case and written canonically.
    location = clean["location"]
    if not location:
        reasons.append("missing location")
    elif location.casefold() not in LOCATION_LOOKUP:
        reasons.append("invalid location")
    else:
        clean["location"] = LOCATION_LOOKUP[location.casefold()]

    genus = clean["genus"]
    genus_valid = genus.casefold() in GENUS_LOOKUP
    if not genus:
        reasons.append("missing genus")
    elif not genus_valid:
        reasons.append("invalid genus")
    else:
        clean["genus"] = GENUS_LOOKUP[genus.casefold()]

    species = clean["species"]
    species_valid = species.casefold() in SPECIES_LOOKUP
    if not species:
        reasons.append("missing species")
    elif not species_valid:
        reasons.append("invalid species")
    else:
        clean["species"] = SPECIES_LOOKUP[species.casefold()]

    # The pairing is checked only when both names are individually recognised.
    if genus_valid and species_valid and clean["species"] not in TAXA[clean["genus"]]:
        reasons.append("invalid genus/species combination")

    # Distance must be in (0, 100]; angle must be in (0, 90).
    for field, upper_bound, include_upper in (
        ("distance_m", 100, True),
        ("angle_degrees", 90, False),
    ):
        value = clean[field]
        if not value:
            reasons.append(f"missing {field}")
            continue
        if NUMBER_PATTERN.fullmatch(value) is None:
            reasons.append(f"invalid {field}")
            continue
        number = float(value)
        # A huge exponent such as 1e999 overflows to inf, which is not finite.
        if not math.isfinite(number):
            reasons.append(f"invalid {field}")
            continue
        if number <= 0 or (number > upper_bound if include_upper else number >= upper_bound):
            reasons.append(f"{field} out of range")
            continue
        clean[field] = decimal_text(number)

    if reasons:
        return None, reasons
    return clean, []


def process_records(
    numbered_rows: Iterable[tuple[int, dict[str, str]]],
) -> tuple[list[dict[str, str]], list[dict[str, str]]]:
    """Sort records into accepted rows and issue reports.

    numbered_rows holds (line number, row) pairs as returned by
    load_records(); the line number is reported as source_row. Rows are
    processed in file order, so the first valid row with an identifier
    reserves it.
    """
    accepted_ids: set[str] = set()
    clean_records: list[dict[str, str]] = []
    issues: list[dict[str, str]] = []

    for source_row, row in numbered_rows:
        cleaned, reasons = validate_record(row, accepted_ids)
        if cleaned is not None:
            clean_records.append(cleaned)
            accepted_ids.add(cleaned["record_id"])
        else:
            issues.append({
                "source_row": str(source_row),
                "record_id": (row.get("record_id") or "").strip(),
                "reasons": "; ".join(reasons),
            })
    clean_records.sort(key=lambda record: record["record_id"])
    return clean_records, issues


def summarise_oaks(clean_records: Iterable[dict[str, str]]) -> list[dict[str, str]]:
    """Count accepted oak records by species."""
    counts: dict[str, int] = {}
    for record in clean_records:
        if record["genus"] == "Quercus":
            species = record["species"]
            counts[species] = counts.get(species, 0) + 1
    return [{"species": species, "count": str(counts[species])} for species in sorted(counts)]


def write_csv(
    path: Path,
    fieldnames: list[str],
    rows: Iterable[dict[str, str]],
) -> None:
    """Write rows to a CSV file, replacing an older copy."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as destination:
        writer = csv.DictWriter(destination, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    """Clean the survey and write the three result files."""
    clean_records, issues = process_records(load_records())
    oak_counts = summarise_oaks(clean_records)

    write_csv(
        RESULTS_DIR / "silwood_trees_clean.csv",
        INPUT_FIELDS,
        clean_records,
    )
    write_csv(
        RESULTS_DIR / "silwood_tree_issues.csv",
        ISSUE_FIELDS,
        issues,
    )
    write_csv(
        RESULTS_DIR / "oak_species_counts.csv",
        OAK_COUNT_FIELDS,
        oak_counts,
    )


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        # A missing, unreadable or malformed input stops the program with a
        # clear message and exit status 1 instead of a traceback. The input is
        # read and checked before any output is written, so results/ is left
        # as it was.
        sys.exit(f"Error: {error}")
