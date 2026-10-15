# Bootcamp Assignment Repository

**Author:** Lixuan Zhu  
**Course:** [MulQuaBio (MQB)](https://mulquabio.github.io/MQB/intro.html)

## Overview

- **Assignment 1 — Unix and Shell Scripting:** FASTA exercises and two delimited-text conversion scripts.
- **Assignment 2 — Python Tree-survey Validation:** Validation of synthetic Silwood tree records, reporting excluded observations and summarising accepted oak records.

## Repository Structure

```text
CMEECourseWork/
├── README.md
├── .gitignore
├── code/
│   ├── clean_silwood_trees.py
│   ├── test_silwood_trees.py
│   ├── csvtospace.sh
│   ├── tabtocsv.sh
│   └── unixPrac1.txt
├── data/
│   ├── fasta/
│   ├── temperatures/
│   ├── silwood_trees_metadata.md
│   ├── silwood_trees_raw.csv
│   └── tab-example.tsv
├── results/                      # generated outputs
└── sandbox/                      # temporary work
```

## Requirements

Unix/Linux, Bash, Python 3 and standard command-line utilities. Run all commands from the repository root.

## Assignment 1 — Unix and Shell Scripting

- `unixPrac1.txt`: Unix/FASTA exercises and explanations.
- `tabtocsv.sh`: Converts tab-separated text to comma-separated text.
- `csvtospace.sh`: Replaces commas with spaces in a CSV file.

```bash
bash code/tabtocsv.sh data/tab-example.tsv
bash code/csvtospace.sh results/tab-example.tsv.csv
```

Both scripts write to `results/`. The second command uses the output produced by the first.

## Assignment 2 — Python Tree-survey Validation

**Inputs:** `data/silwood_trees_raw.csv` (unchanged source data) and `data/silwood_trees_metadata.md` (validation rules and output specifications).  
**Implementation:** `code/clean_silwood_trees.py`; **tests:** `code/test_silwood_trees.py` (to be added).

### Workflow (pseudocode)

```text
Read the source CSV.
For each row, validate fields against the metadata.
  If valid: retain the cleaned record and its accepted ID.
  Otherwise: record the original row and all rejection reasons.
Count oak species from accepted records only.
Write the cleaned records, issues and oak counts as separate CSV files.
```

### Run and Test

```bash
python3 code/clean_silwood_trees.py
python3 code/test_silwood_trees.py
```

**Outputs:**

| File | Content |
| --- | --- |
| `results/silwood_trees_clean.csv` | Accepted and cleaned records |
| `results/silwood_tree_issues.csv` | Rejected rows and reasons |
| `results/oak_species_counts.csv` | Oak counts by species |

## AI Assistance

ChatGPT  was used for translation, documentation refinement, and clarification of programming
concepts. Suggestions were independently reviewed against the course materials and assignment 
requirements, with code functionality checked through local execution.

## References

- [MulQuaBio course](https://mulquabio.github.io/MQB/intro.html)
- [Tree-survey practical](https://mulquabio.github.io/MQB/notebooks/python.html#practical-validating-tree-survey-records)