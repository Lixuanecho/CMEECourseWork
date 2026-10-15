#!/usr/bin/env python3
"""Validate and clean the synthetic Silwood tree survey."""

from __future__ import annotations

import csv
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


def load_records(path: Path = INPUT_PATH) -> list[dict[str, str]]:
    """Read the survey and check its column names."""
    with path.open(newline="", encoding="utf-8") as source:
        reader = csv.DictReader(source)
        if reader.fieldnames != INPUT_FIELDS:
            raise ValueError(
                f"Expected columns {INPUT_FIELDS}, found {reader.fieldnames}"
            )
        return list(reader)


def validate_record(
    row: dict[str, str],
    source_row: int,
    accepted_ids: set[str],
) -> tuple[dict[str, str] | None, list[str]]:
    """Clean one record, or return the reasons it cannot be used."""
    import math
    import re

    locations = ("Silwood Bottom", "Nash's Field", "Manor House", "Reactor Wood")
    taxa = {
        "Quercus": ("robur", "petraea"),
        "Acer": ("pseudoplatanus",),
        "Betula": ("pendula",),
        "Fagus": ("sylvatica",),
        "Fraxinus": ("excelsior",),
    }
    location_lookup = {name.casefold(): name for name in locations}
    genus_lookup = {name.casefold(): name for name in taxa}
    species_lookup = {
        species.casefold(): species
        for species_names in taxa.values()
        for species in species_names
    }

    clean = {
        field: (row.get(field) or "").strip()
        for field in INPUT_FIELDS
    }
    reasons = []

    record_id = clean["record_id"]
    if not record_id:
        reasons.append("missing record_id")
    elif re.fullmatch(r"ST[0-9]{3}", record_id) is None:
        reasons.append("invalid record_id")
    elif record_id in accepted_ids:
        reasons.append("duplicate record_id")

    location = clean["location"]
    if not location:
        reasons.append("missing location")
    elif location.casefold() not in location_lookup:
        reasons.append("invalid location")
    else:
        clean["location"] = location_lookup[location.casefold()]

    genus = clean["genus"]
    genus_valid = genus.casefold() in genus_lookup
    if not genus:
        reasons.append("missing genus")
    elif not genus_valid:
        reasons.append("invalid genus")
    else:
        clean["genus"] = genus_lookup[genus.casefold()]

    species = clean["species"]
    species_valid = species.casefold() in species_lookup
    if not species:
        reasons.append("missing species")
    elif not species_valid:
        reasons.append("invalid species")
    else:
        clean["species"] = species_lookup[species.casefold()]

    if genus_valid and species_valid and clean["species"] not in taxa[clean["genus"]]:
        reasons.append("invalid genus/species combination")

    for field, upper_bound, include_upper in (
        ("distance_m", 100, True),
        ("angle_degrees", 90, False),
    ):
        value = clean[field]
        if not value:
            reasons.append(f"missing {field}")
            continue
        try:
            number = float(value)
        except ValueError:
            reasons.append(f"invalid {field}")
            continue
        if not math.isfinite(number):
            reasons.append(f"invalid {field}")
            continue
        if number <= 0 or (number > upper_bound if include_upper else number >= upper_bound):
            reasons.append(f"{field} out of range")
            continue
        clean[field] = str(number)

    if reasons:
        return None, reasons
    return clean, []



def process_records(
    rows: Iterable[dict[str, str]],
) -> tuple[list[dict[str, str]], list[dict[str, str]]]:
    """Sort records into accepted rows and issue reports."""
    accepted_ids: set[str] = set()
    clean_records: list[dict[str, str]] = []
    issues: list[dict[str, str]] = []

    for source_row, row in enumerate(rows, start=2):
        cleaned, reasons = validate_record(row, source_row, accepted_ids)
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
    main()
