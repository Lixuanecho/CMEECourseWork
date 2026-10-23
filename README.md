# Bootcamp Assignment Repository

### Repository structure

```text
CMEECourseWork/
├── README.md
├── .gitignore
├── code/
│   ├── unixPrac1.txt                
│   ├── tabtocsv.sh     
│   ├── csvtospace.sh       
│   ├── clean_silwood_trees.py
│   ├── test_silwood_trees.py
│   ├── TreeHeight.R
│   ├── get_TreeHeight.R
│   ├── run_get_TreeHeight.sh
│   └── pound_hill_analysis.R
├── data/
│   ├── fasta/
│   ├── temperatures/
│   ├── tab-example.tsv
│   ├── silwood_trees_raw.csv
│   ├── silwood_trees_metadata.md
│   ├── trees.csv
│   ├── pound_hill_data.csv
│   └── pound_hill_meta_data.csv
├── results/                         # generated outputs; Git-ignored
└── sandbox/                         # temporary work; Git-ignored
```


**Author:** Lixuan Zhu  
**Module:** Biological Computing Bootcamp (CMEE, Imperial College London)  
**Reference:** [MulQuaBio (MQB)](https://mulquabio.github.io/MQB/intro.html)

**Environment:** Unix/Linux; GNU Bash 5.3.9, Python 3.14.4 and R 4.5.2. The documented R analyses use base R.


# Assignment 1 — UNIX and Bash

- `code/unixPrac1.txt`: five FASTA exercises covering line counts, sequence extraction and length, `ATGC` occurrences and the AT/GC ratio, with commands, results and explanations.
- `code/tabtocsv.sh`: replaces tabs with commas in a text file.
- `code/csvtospace.sh`: replaces commas with spaces in a CSV file.

### How to run

The scripts use Bash and standard UNIX utilities (`tr`, `wc`, `tail`, `grep`, `awk` and `mkdir`). The FASTA ratio uses `awk`.

Run the converters from the **repository root**:

```bash
bash code/tabtocsv.sh data/tab-example.tsv
bash code/csvtospace.sh data/temperatures/1800.csv
```

These commands generate `results/tab-example.tsv.csv` and `results/1800.csv.txt`, respectively. To convert all temperature files:

```bash
for file in data/temperatures/*.csv; do
    bash code/csvtospace.sh "$file"
done
```

For the FASTA questions, enter `code/` and run each numbered command in `unixPrac1.txt` separately. The text file is **not** an executable script.

```bash
cd code
cat unixPrac1.txt
# Run the numbered commands individually, then return to the root:
cd ..
```

### Testing

```bash
# Check shell syntax.
bash -n code/tabtocsv.sh code/csvtospace.sh

# Check the outputs against direct delimiter substitutions.
tr '\t' ',' < data/tab-example.tsv | cmp - results/tab-example.tsv.csv
tr ',' ' ' < data/temperatures/1800.csv | cmp - results/1800.csv.txt
```

### AI use
On October 8 and October 9, I used ChatGPT as a tutor to learn Python syntax and rules.

# Assignment 2 — Silwood tree survey

This assignment cleans and validates synthetic tree survey data against the supplied metadata and summarises accepted oak records.

| Type | File | Contents |
| --- | --- | --- |
| Input | `data/silwood_trees_raw.csv` | Unmodified synthetic source records. |
| Input | `data/silwood_trees_metadata.md` | Required fields, accepted values, validation rules and output contracts. |
| Output | `results/silwood_trees_clean.csv` | Accepted, standardised records sorted by record ID. |
| Output | `results/silwood_tree_issues.csv` | Rejected records with original source row, ID and ordered rejection reasons. |
| Output | `results/oak_species_counts.csv` | Accepted `Quercus` records counted by species, sorted by species. |

### Pseudocode — `clean_silwood_trees.py`

```text
Read the CSV and verify its header.
Initialise accepted records, issues, and accepted IDs.
For each source row (starting at line 2):
    Trim text; validate fields against metadata-defined rules.
    Collect all rejection reasons in the required order.
    If invalid: record source row, ID and reasons.
    Otherwise: store the canonical record and reserve its ID.
Sort accepted records by ID.
Count accepted Quercus records by species; sort species names.
Replace the three output CSV files.
```

### Test notes

The test script uses Python's `unittest` framework with 23 assertion-based tests. These verify text standardisation, missing and invalid values, duplicate IDs, record sorting, ordered rejection reasons, and oak species counts. Additional tests check that rejected records do not reserve their IDs, invalid oaks are excluded from species counts, and repeated runs produce consistent outputs without modifying the source data.

**Run from the repository root:**

```bash
python3 -B code/clean_silwood_trees.py
python3 -B code/test_silwood_trees.py
```

All 23 tests passed, producing `Ran 23 tests ... OK`. The supplied seven-record survey produced four accepted and three rejected records, with oak counts of `petraea: 1` and `robur: 2`.

The cleaner follows the supplied synthetic survey schema; missing values and misspellings are rejected rather than inferred.

### AI use
On October 16, I used ChatGPT as a tutor and gained insights into handling error messages, testing inputs, and the wording of README files.

# Assignment 3 — R practicals

## 3.1 Tree-height Practicals

### 1. `TreeHeight.R` — Supplied Tree Measurements

**Input:** `data/trees.csv` (120 records; `Species`, `Distance.m`, `Angle.degrees`).

**Output:** `results/TreeHts.csv`, preserving the original data and adding a `height_m` column.

**Method:** Calculate tree height using:

`height_m = Distance.m × tan(Angle.degrees × π / 180)`

Validate column names and ensure measurements are finite and within the required ranges (`0 < distance ≤ 100 m`, `0 < angle < 90°`).

**Run** from the repository root:

```bash
Rscript code/TreeHeight.R
```

Alternatively, run in an R session started from the repository root:

```r
source("code/TreeHeight.R")
```

**Check:** The output should contain 121 lines (header + 120 records). Verify that the fourth record matches an independent trigonometric calculation. For a simple test case, a distance of 8 m at 45° should produce a height of 8 m. Rerunning the script should overwrite the existing output.

```bash
wc -l results/TreeHts.csv

Rscript -e 'x <- read.csv("results/TreeHts.csv"); stopifnot(isTRUE(all.equal(x$height_m[4], x$Distance.m[4] * tan(x$Angle.degrees[4] * pi / 180))))'
```

The first command checks the output line count; the second independently verifies the fourth height calculation using `stopifnot()`.

---

### 2. `get_TreeHeight.R` — Generalised Tree-height Script

**Input:** Exactly one readable CSV file containing `Species`, `Distance.m`, and `Angle.degrees`.

**Output:** `results/<input-basename>_treeheights.csv` (e.g., `results/trees_treeheights.csv`), preserving row order and adding `height_m`.

**Run** from the repository root:

```bash
Rscript code/get_TreeHeight.R data/trees.csv
```

**Check:** Create a one-row CSV with a distance of 8 m and an angle of 45°. The expected height is 8 m.

```bash
mkdir -p sandbox
printf 'Species,Distance.m,Angle.degrees\nTest,8,45\n' > sandbox/tree_test.csv

Rscript code/get_TreeHeight.R sandbox/tree_test.csv

Rscript -e 'x <- read.csv("results/tree_test_treeheights.csv"); stopifnot(nrow(x) == 1L, isTRUE(all.equal(x$height_m[1], 8)))'
```

`mkdir -p` creates the test directory if needed, while `printf` generates the test CSV. The script processes the file, and `stopifnot()` verifies that the output contains exactly one record with the expected height.

**Interactive debugging:** Temporarily insert `browser()` immediately before the height calculation.

```r
browser()
```

Start R from the repository root:

```bash
R --vanilla --args data/trees.csv
```

Then execute:

```r
source("code/get_TreeHeight.R")
```

Execution pauses at `browser()`, allowing inspection of the measurements and independent verification of the height calculation. Remove `browser()` after debugging.

---

### 3. `run_get_TreeHeight.sh` — Bash Automation

**Run / Check** from the repository root:

```bash
bash code/run_get_TreeHeight.sh
test -s results/trees_treeheights.csv && echo PASS
```

**Expected:** `PASS` indicates that the output file exists and is non-empty. The script uses `set -e` to stop execution if a command fails.


## 3.2 Cultivation timing and plant species richness at Pound Hill


**Research question:** How does mean plant species richness per quadrat vary among the March, May and October cultivation treatments?

**Run** from the repository root:

```bash
Rscript code/pound_hill_analysis.R
```

**Inputs:** `data/pound_hill_data.csv` and `data/pound_hill_meta_data.csv`.

**Outputs:** 

| Output file | Description |
| --- | --- |
| `results/pound_hill_plot_richness.csv` | Mean species richness for each of the 12 plots (`Cultivation`, `Block`, `Plot`, `MeanRichness`). |
| `results/pound_hill_plot_richness.pdf` | Plot-level richness across March, May and October treatments, showing individual plots and treatment means. |
| `results/pound_hill_plot_abundance.csv` | Mean total abundance per quadrat, aggregated to the plot level. |
| `results/pound_hill_plot_abundance.pdf` | Plot-level abundance across cultivation treatments. |

**Method:** Species counts are reshaped to long format with `tidyr::pivot_longer()`. Metadata-defined blank counts represent observed absences and are converted to zero; all counts must be numeric, non-missing and non-negative. Each quadrat is uniquely identified by `Cultivation`, `Block`, `Plot` and `Quadrat`. Richness (number of species with `Count > 0`) and abundance (sum of individual counts) are calculated per quadrat, then averaged within plots. Because plots contain unequal numbers of quadrats (3–6), treatment comparisons use plot-level means to give each of the four replicate plots per treatment equal weight.

**Check:** The script checks count validity and reports 41 species, 59 quadrats and 12 plots; the long-format data contain 2,419 rows (59 × 41) and six columns. Verify that the richness output contains 12 plots, with four per treatment:

```bash
Rscript -e 'x <- read.csv("results/pound_hill_plot_richness.csv"); stopifnot(nrow(x) == 12L, all(table(x$Cultivation) == 4L))'
```

To verify reproducibility, save the output, rerun the analysis and compare the files:

```bash
cp results/pound_hill_plot_richness.csv /tmp/pound_hill_first.csv
Rscript code/pound_hill_analysis.R
cmp /tmp/pound_hill_first.csv results/pound_hill_plot_richness.csv
```

A successful `stopifnot()` check and identical CSV files produce no output. 

**Interpretation:** See the comments at the end of `code/pound_hill_analysis.R`.

### AI use
Between October 20 and 23, I used ChatGPT to understand errors and concepts and to debug my draft.