#!/usr/bin/env python3
"""Unit and integration tests for the synthetic Silwood tree-survey workflow."""

import csv
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import clean_silwood_trees as trees


def make_record(**changes):
    """Create an independent, valid survey row with optional overrides."""
    row = {
        "record_id": "ST001", "location": "Silwood Bottom",
        "genus": "Quercus", "species": "robur",
        "distance_m": "12.5", "angle_degrees": "35",
    }
    row.update(changes)
    return row


class TestValidation(unittest.TestCase):
    """Exercise every field and rejection category in the metadata."""

    def check_reasons(self, expected, **changes):
        cleaned, reasons = trees.validate_record(make_record(**changes), 2, set())
        self.assertIsNone(cleaned)
        self.assertEqual(reasons, expected)

    def test_canonicalisation(self):
        row = make_record(record_id=" ST001 ", location=" nASH's fIELD ",
                          genus=" quERCUS ", species=" ROBUR ")
        original = row.copy()
        accepted_ids = set()
        cleaned, reasons = trees.validate_record(row, 2, accepted_ids)
        self.assertEqual(reasons, [])
        self.assertEqual(cleaned, make_record(location="Nash's Field",
                                             distance_m="12.5", angle_degrees="35.0"))
        self.assertEqual(row, original)
        self.assertEqual(accepted_ids, set())

    def test_all_permitted_locations(self):
        for location in ("Silwood Bottom", "Nash's Field", "Manor House", "Reactor Wood"):
            with self.subTest(location=location):
                cleaned, reasons = trees.validate_record(
                    make_record(location=f" {location.swapcase()} "), 2, set())
                self.assertEqual(reasons, [])
                self.assertEqual(cleaned["location"], location)

    def test_all_permitted_taxa(self):
        for genus, species in (("Quercus", "robur"), ("Quercus", "petraea"),
                               ("Acer", "pseudoplatanus"), ("Betula", "pendula"),
                               ("Fagus", "sylvatica"), ("Fraxinus", "excelsior")):
            with self.subTest(genus=genus, species=species):
                cleaned, reasons = trees.validate_record(
                    make_record(genus=genus.swapcase(), species=species.upper()), 2, set())
                self.assertEqual(reasons, [])
                self.assertEqual((cleaned["genus"], cleaned["species"]), (genus, species))

    def test_missing_fields(self):
        for field in trees.INPUT_FIELDS:
            for missing in ("", "   ", None):
                with self.subTest(field=field, missing=missing):
                    self.check_reasons([f"missing {field}"], **{field: missing})

    def test_invalid_id(self):
        for value in ("st001", "ST01", "ST0001", "XX001", "ST12A", "ST１２３"):
            with self.subTest(value=value):
                self.check_reasons(["invalid record_id"], record_id=value)

    def test_invalid_location_and_spelling(self):
        self.check_reasons(["invalid location"], location="Silwood Botom")
        self.check_reasons(["invalid location"], location="Unknown")

    def test_invalid_genus_and_species(self):
        self.check_reasons(["invalid genus"], genus="Querqus")
        self.check_reasons(["invalid species"], species="roburx")
        self.check_reasons(["invalid genus/species combination"],
                           genus="Acer", species="robur")
        self.check_reasons(["invalid genus", "invalid species"],
                           genus="Other", species="other")

    def test_distance_bounds(self):
        for value in ("0", "-1", "100.0001"):
            with self.subTest(value=value):
                self.check_reasons(["distance_m out of range"], distance_m=value)
        for value in ("0.001", "100"):
            with self.subTest(value=value):
                accepted, reasons = trees.validate_record(
                    make_record(distance_m=value), 2, set())
                self.assertEqual(reasons, [])
                self.assertIsNotNone(accepted)

    def test_angle_bounds(self):
        for value in ("0", "-1", "90", "100"):
            with self.subTest(value=value):
                self.check_reasons(["angle_degrees out of range"], angle_degrees=value)
        for value in ("0.001", "89.999"):
            with self.subTest(value=value):
                accepted, reasons = trees.validate_record(
                    make_record(angle_degrees=value), 2, set())
                self.assertEqual(reasons, [])
                self.assertIsNotNone(accepted)

    def test_non_finite_and_unparseable_numbers(self):
        for field in ("distance_m", "angle_degrees"):
            for value in ("nan", "NaN", "inf", "-inf", "Infinity", "abc"):
                with self.subTest(field=field, value=value):
                    self.check_reasons([f"invalid {field}"], **{field: value})

    def test_combined_reasons_in_metadata_order(self):
        self.check_reasons([
            "invalid record_id", "invalid location", "invalid genus",
            "invalid species", "invalid distance_m", "angle_degrees out of range",
        ], record_id="bad", location="Unknown", genus="Unknown",
           species="Unknown", distance_m="nan", angle_degrees="90")
        self.check_reasons([
            "invalid genus/species combination", "distance_m out of range",
            "invalid angle_degrees",
        ], genus="Acer", species="robur", distance_m="0", angle_degrees="bad")

    def test_duplicate_id(self):
        cleaned, reasons = trees.validate_record(make_record(), 3, {"ST001"})
        self.assertIsNone(cleaned)
        self.assertEqual(reasons, ["duplicate record_id"])

    def test_duplicate_and_other_error(self):
        cleaned, reasons = trees.validate_record(
            make_record(location="Unknown"), 3, {"ST001"})
        self.assertIsNone(cleaned)
        self.assertEqual(reasons, ["duplicate record_id", "invalid location"])


class TestProcessing(unittest.TestCase):
    """Check acceptance, rejected lines, ordering, and counts."""

    def test_sort_accepted_and_keep_issue_source_order(self):
        rows = [make_record(record_id="ST002"),
                make_record(record_id="ST003", distance_m="0"),
                make_record(record_id="ST001"),
                make_record(record_id="bad", location="Wrong")]
        accepted, issues = trees.process_records(rows)
        self.assertEqual([row["record_id"] for row in accepted], ["ST001", "ST002"])
        self.assertEqual(issues, [
            {"source_row": "3", "record_id": "ST003",
             "reasons": "distance_m out of range"},
            {"source_row": "5", "record_id": "bad",
             "reasons": "invalid record_id; invalid location"},
        ])

    def test_invalid_row_does_not_reserve_identifier(self):
        rows = [make_record(distance_m="bad"), make_record()]
        accepted, issues = trees.process_records(rows)
        self.assertEqual(len(accepted), 1)
        self.assertEqual(accepted[0]["record_id"], "ST001")
        self.assertEqual(issues[0]["reasons"], "invalid distance_m")

    def test_first_accepted_id_is_reserved(self):
        accepted, issues = trees.process_records([make_record(), make_record()])
        self.assertEqual(len(accepted), 1)
        self.assertEqual(issues[0]["reasons"], "duplicate record_id")

    def test_oak_counts_exclude_non_oaks(self):
        rows = [make_record(), make_record(record_id="ST002", species="petraea"),
                make_record(record_id="ST003", genus="Acer", species="pseudoplatanus"),
                make_record(record_id="ST004")]
        accepted, _ = trees.process_records(rows)
        self.assertEqual(trees.summarise_oaks(accepted), [
            {"species": "petraea", "count": "1"},
            {"species": "robur", "count": "2"},
        ])
        self.assertEqual(trees.summarise_oaks([]), [])

    def test_oak_near_match_rejected(self):
        """A near-match genus must not be accepted as an oak."""

        rows = [
            make_record(record_id="ST001"),
            make_record(
                record_id="ST002",
                genus="Quercuss",
                species="robur",
            ),
        ]

        accepted, issues = trees.process_records(rows)

        self.assertEqual(len(accepted), 1)
        self.assertEqual(len(issues), 1)

        self.assertEqual(
            trees.summarise_oaks(accepted),
            [{"species": "robur", "count": "1"}],
        )


    def test_rejected_oak_excluded_from_summary(self):
        """An invalid Quercus observation must not affect oak counts."""
        rows = [
            make_record(record_id="ST001", genus="Quercus", species="robur"),
            make_record(record_id="ST002", genus="Quercus", species="robur",
                        distance_m="0"),
        ]

        clean_records, issues = trees.process_records(rows)
        self.assertEqual([row["record_id"] for row in clean_records], ["ST001"])
        self.assertEqual(issues, [{
            "source_row": "3", "record_id": "ST002",
            "reasons": "distance_m out of range",
        }])
        self.assertEqual(trees.summarise_oaks(clean_records), [
            {"species": "robur", "count": "1"},
        ])


class TestFileWorkflow(unittest.TestCase):
    """Test I/O, stable reruns, and creation of the results directory."""

    def test_import_has_no_side_effects(self):
        """Importing the module must not invoke the workflow or create outputs."""
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            module_dir = Path(trees.__file__).resolve().parent
            environment = os.environ.copy()
            environment["PYTHONDONTWRITEBYTECODE"] = "1"
            script = (
                "import sys; "
                f"sys.path.insert(0, {str(module_dir)!r}); "
                "import clean_silwood_trees"
            )
            outcome = subprocess.run(
                [sys.executable, "-B", "-c", script],
                cwd=root,
                env=environment,
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(outcome.returncode, 0, outcome.stderr)
            self.assertEqual(outcome.stdout, "")
            self.assertEqual(outcome.stderr, "")
            self.assertEqual(list(root.iterdir()), [])

    def test_header_validation(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "raw.csv"
            path.write_text("wrong,header\na,b\n", encoding="utf-8")
            with self.assertRaises(ValueError):
                trees.load_records(path)

    def test_main_writes_all_outputs_and_preserves_input(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            source = root / "data" / "silwood_trees_raw.csv"
            source.parent.mkdir()
            with source.open("w", newline="", encoding="utf-8") as handle:
                writer = csv.DictWriter(handle, fieldnames=trees.INPUT_FIELDS)
                writer.writeheader()
                writer.writerows([
                    make_record(record_id="ST002", genus="Acer", species="pseudoplatanus"),
                    make_record(record_id="ST001"),
                    make_record(record_id="ST003", distance_m="nan"),
                ])
            original_bytes = source.read_bytes()
            results = root / "results"
            self.assertFalse(results.exists())
            original_loader = trees.load_records
            with patch.object(trees, "load_records", side_effect=lambda: original_loader(source)):
                with patch.object(trees, "RESULTS_DIR", results):
                    trees.main()
            expected_names = {"silwood_trees_clean.csv", "silwood_tree_issues.csv",
                              "oak_species_counts.csv"}
            self.assertEqual({p.name for p in results.iterdir()}, expected_names)
            self.assertEqual(source.read_bytes(), original_bytes)
            with (results / "silwood_trees_clean.csv").open(newline="") as handle:
                clean = list(csv.DictReader(handle))
            self.assertEqual([r["record_id"] for r in clean], ["ST001", "ST002"])
            with (results / "silwood_tree_issues.csv").open(newline="") as handle:
                issues = list(csv.DictReader(handle))
            self.assertEqual(issues, [{"source_row": "4", "record_id": "ST003",
                                       "reasons": "invalid distance_m"}])
            with (results / "oak_species_counts.csv").open(newline="") as handle:
                counts = list(csv.DictReader(handle))
            self.assertEqual(counts, [{"species": "robur", "count": "1"}])
            first_run = {p.name: p.read_bytes() for p in results.iterdir()}
            with patch.object(trees, "load_records", side_effect=lambda: original_loader(source)):
                with patch.object(trees, "RESULTS_DIR", results):
                    trees.main()
            self.assertEqual(first_run, {p.name: p.read_bytes() for p in results.iterdir()})
            self.assertEqual(source.read_bytes(), original_bytes)

    def test_main_does_not_write_when_input_header_is_invalid(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            source = root / "bad.csv"
            source.write_text("bad,columns\nx,y\n", encoding="utf-8")
            original_loader = trees.load_records
            with patch.object(trees, "load_records", side_effect=lambda: original_loader(source)):
                with patch.object(trees, "RESULTS_DIR", root / "results"):
                    with self.assertRaises(ValueError):
                        trees.main()
            self.assertFalse((root / "results").exists())


if __name__ == "__main__":
    unittest.main()