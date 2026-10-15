#!/usr/bin/env python3
"""Unit tests for the Silwood tree survey validation workflow."""

import unittest

from clean_silwood_trees import (
    validate_record,
    process_records,
    summarise_oaks,
)


class TestSilwoodTrees(unittest.TestCase):
    """Test tree record validation and processing."""

    def test_missing_record_id(self):
        """Reject a record with a missing identifier."""

        row = {
            "record_id": "",
            "location": "Silwood Bottom",
            "genus": "Quercus",
            "species": "robur",
            "distance_m": "10",
            "angle_degrees": "45",
        }

        cleaned, reasons = validate_record(row, 2, set())

        self.assertIsNone(cleaned)
        self.assertIn("missing record_id", reasons)


if __name__ == "__main__":
    unittest.main()