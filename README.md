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

## 3.1 Tree-height practicals

`TreeHeight.R` and `get_TreeHeight.R` use the same formula:

`height_m = Distance.m × tan(Angle.degrees × π / 180)`

| | `TreeHeight.R` | `get_TreeHeight.R` |
| --- | --- | --- |
| Input | Fixed to `data/trees.csv` | One CSV path given on the command line |
| Accepted rows | Exactly 120 rows | 1 row or more |
| Output | `results/TreeHts.csv` | `results/<input file name>_treeheights.csv` |
| Output columns | `Species,Distance.m,Angle.degrees,height_m` | `Species,Distance.m,Angle.degrees,height_m` |

Both scripts reject input with:

- Wrong or missing column names
- Non-numeric or non-finite values
- `Distance.m` outside the range `(0, 100]` m
- `Angle.degrees` outside the range `(0, 90)`°

For a bad measurement, the error names the column and the failing data row(s), for example `Invalid data row(s): 4`.

Both scripts replace their output file on rerun and write it only after all checks pass, so bad input never creates or overwrites a result.

---

### 1. `TreeHeight.R`

This script defines the function `TreeHeight(degrees, distance)`, which converts the angle from degrees to radians and returns `distance × tan(radians)`. It prints the example `TreeHeight(37, 40)`, then applies the function to every row of `data/trees.csv`.

**Input:** `data/trees.csv` (kept unchanged)

**Output:** `results/TreeHts.csv`. The three input columns keep their original order, and `height_m` is added as the fourth column.

**Run** (from the repository root):

```bash
Rscript code/TreeHeight.R
```

or, in an R session started at the repository root:

```r
source("code/TreeHeight.R")
```

**Tests**

**Test 1: Header and row count.**

```bash
wc -l results/TreeHts.csv          # Expected: 121 (header + 120 records)
head -n 1 results/TreeHts.csv      # Expected: "Species","Distance.m","Angle.degrees","height_m"
```

**Test 2: Example call.** The script prints the result of `print(TreeHeight(37, 40))`:

```text
[1] 30.14216
```

**Test 3: Row order.** The first three output columns must equal the input table:

```bash
Rscript -e 'a <- read.csv("data/trees.csv"); b <- read.csv("results/TreeHts.csv"); stopifnot(isTRUE(all.equal(a, b[1:3]))); cat("PASS\n")'
```

**Test 4: Rerun.** A rerun replaces the result rather than adding rows:

```bash
Rscript code/TreeHeight.R
wc -l results/TreeHts.csv          # Expected: still 121
```

**Test 5: One record checked independently.** Record 4 was calculated on a scientific calculator in degree mode (DEG). The calculator takes the angle in degrees directly, so this check does not reuse the script's degree-to-radian step:

```bash
sed -n 5p results/TreeHts.csv      # Line 5 = header + record 4
```

| Step | Value | Unit |
| --- | --- | --- |
| Species | Fraxinus excelsior | – |
| `Distance.m` (input) | 34.6166691975668 | m |
| `Angle.degrees` (input) | 23.336126555223 | ° |
| Calculator (DEG): tan(23.336126555223) | 0.431416 | – |
| Calculator: 34.6166691975668 × 0.431416 | 14.934 | m |
| Script output `height_m` | 14.934175 | m |
| Agreement | Difference < 0.001 | m |

Why the value is plausible:

- The angle is less than 45°, and tan(45°) = 1, so the height must be less than the distance (14.9 m < 34.6 m).
- tan(23.3°) is about 0.43, so the height should be a little under half the distance.
- A height of about 15 m is biologically plausible for an ash tree.

**Test 6: Invalid measurement.** The script rejects it and does not overwrite the result. `TreeHeight.R` only reads `data/trees.csv`, so this test changes one value in that file and then restores it. The columns and the 120 rows are kept, so only the distance check can fail:

```bash
mkdir -p sandbox
cp data/trees.csv sandbox/trees_backup.csv                # Back up the supplied file
md5sum results/TreeHts.csv > sandbox/TreeHts_before.md5   # Fingerprint of the current result
sed -i '5s/,34.6166691975668,/,-34.6166691975668,/' data/trees.csv   # Record 4 distance -> negative
Rscript code/TreeHeight.R
# Expected error: Distance.m must be finite with 0 < distance <= 100. Invalid data row(s): 4
md5sum -c sandbox/TreeHts_before.md5                      # Expected: results/TreeHts.csv: OK (not overwritten)
cp sandbox/trees_backup.csv data/trees.csv                # Restore the supplied file
cmp data/trees.csv sandbox/trees_backup.csv && echo RESTORED
```

---

### 2. `get_TreeHeight.R`

This script turns the fixed-dataset program into a general tool that safely handles any data in the same format. It reuses the input checks, the `TreeHeight()` function and the four-column output of `TreeHeight.R`. The function is copied rather than sourced, because sourcing `TreeHeight.R` would run that whole script and rewrite `results/TreeHts.csv`.

**Input:** One readable CSV file given as a command-line argument, with the columns `Species`, `Distance.m` and `Angle.degrees`.

**Output:** `results/<input file name>_treeheights.csv` (for example `results/trees_treeheights.csv`). The rows keep their original order, and `height_m` is added as the fourth column. The input file is never overwritten.

**Run** (from the repository root):

```bash
Rscript code/get_TreeHeight.R data/trees.csv
```

**Tests**

**Test 1: Normal run with the full dataset.**

```bash
wc -l results/trees_treeheights.csv     # Expected: 121
```

**Test 2: Known answer.** At 45°, the height equals the distance, so 8 m at 45° should give 8 m:

```bash
mkdir -p sandbox
printf 'Species,Distance.m,Angle.degrees\nTest,8,45\n' > sandbox/tree_test.csv
Rscript code/get_TreeHeight.R sandbox/tree_test.csv
cat results/tree_test_treeheights.csv   # Expected: height_m = 8
```

**Test 3: Bad arguments.** Each run stops with a useful error:

```bash
Rscript code/get_TreeHeight.R                                  # Expected: usage message (no argument)
Rscript code/get_TreeHeight.R data/trees.csv data/trees.csv    # Expected: usage message (extra argument)
Rscript code/get_TreeHeight.R data/missing.csv                 # Expected: input file does not exist
printf 'Name,Distance.m,Angle.degrees\nTest,8,45\n' > sandbox/bad_header.csv
Rscript code/get_TreeHeight.R sandbox/bad_header.csv           # Expected: CSV must contain exactly: ...
```

**Test 4: Invalid measurement.** The script rejects it and writes no result. The header is correct, and only the distance in data row 2 is invalid:

```bash
printf 'Species,Distance.m,Angle.degrees\nTest,8,45\nTest,-5,30\n' > sandbox/bad_distance.csv
rm -f results/bad_distance_treeheights.csv
Rscript code/get_TreeHeight.R sandbox/bad_distance.csv
# Expected error: Distance.m must be finite with 0 < distance <= 100. Invalid data row(s): 2
test -e results/bad_distance_treeheights.csv || echo "No result written"
```

**Test 5: Both scripts agree.** The two copies of `TreeHeight()` are checked by comparing their outputs for `data/trees.csv`:

```bash
diff results/TreeHts.csv results/trees_treeheights.csv && echo SAME
```

**Debugging with `browser()`.** Following the "Paranoid programming" approach, `browser()` was placed temporarily just before the height-calculation line. R was started from the repository root with `R --vanilla --args data/trees.csv`, and the script was run with `source("code/get_TreeHeight.R")`. In browser mode, the distance and angle of record 4 (34.6167 m, 23.3361°) were inspected, and the expected height (14.934 m) was calculated by hand. Pressing `n` ran the calculation line, and `trees$height_m[4]` matched the prediction. Pressing `c` continued the run, and `browser()` was then removed.

---

### 3. `run_get_TreeHeight.sh`

This script runs `get_TreeHeight.R` with `Rscript`, using `set -e` to stop on any error.

**Input:** `data/trees.csv` (passed to `get_TreeHeight.R`)

**Output:** `results/trees_treeheights.csv`

**Run** (from the repository root):

```bash
bash code/run_get_TreeHeight.sh
```

**Tests**

**Test 1: Non-empty result.**

```bash
test -s results/trees_treeheights.csv && echo PASS   # Expected: PASS
```

---

### Revisions and checks after feedback — 2026/11/22

- Renamed the output column to `height_m`, as the practical specifies.
- Kept `TreeHeight()` in both scripts, because each script must run on its own and no extra files are allowed. `diff` confirms that both outputs are identical (Test 5 of `get_TreeHeight.R`).
- Changed `TreeHeight()` to return the height only; the example call prints it, as in the practical.
- Tested `TreeHeight.R` and `get_TreeHeight.R` separately: row count, row order, rerun, an independently checked record and error messages.
- Used the same header format at the top of both scripts, and added comments to explain decisions.

---

## 3.2 Cultivation timing and plant species richness at Pound Hill

> **Research question:** How does mean plant species richness per quadrat vary among the March, May and October cultivation treatments?

### `pound_hill_analysis.R`

This script calculates mean species richness for each plot and compares the three cultivation treatments. It uses base R only.

**Input:** `data/pound_hill_data.csv` and `data/pound_hill_meta_data.csv`

**Output:** Both files are recreated on every successful run.

| Output file | Contents |
| --- | --- |
| `results/pound_hill_plot_richness.csv` | Mean species richness for each of the 12 plots (`Cultivation`, `Block`, `Plot`, `MeanRichness`). |
| `results/pound_hill_plot_richness.pdf` | Plot-level richness for March, May and October: one labelled point per plot and a line for each treatment mean. |

**Run** (from the repository root):

```bash
Rscript code/pound_hill_analysis.R
```

**Method**

1. **Reshape.** The species table is transposed (one column per quadrat), so it is transposed in base R and reshaped to long format (one row per species × quadrat) with `rep()`.
2. **Blank counts.** The metadata defines blank counts as observed absences, so they are converted to zero. All counts must then be numeric, finite, non-negative integers.
3. **Sampling unit.** Each quadrat is identified by `Cultivation`, `Block`, `Plot` and `Quadrat`.
4. **Richness.** The number of species with `Count > 0` is calculated per quadrat and then averaged within each plot.
5. **Replicates.** Plots hold unequal numbers of quadrats (3–6), so treatments are compared using plot-level means. This gives each of the four replicate plots per treatment equal weight.

**Tests**

**Test 1: Built-in validation.** The script stops with an error if any check fails. A successful run reports 41 species, 59 quadrats, 2,419 long-format rows (59 × 41) and 12 plots, one per treatment in each block.

**Test 2: Figure matches the CSV (built in).** After writing the outputs, the script re-reads the saved CSV and stops if any plotted point or treatment-mean line differs from it. A successful run prints:

```text
Figure check passed: 12 points and 3 treatment means match the CSV.
  march    mean = 7.81; plot range = 6.33-10.00
  may      mean = 9.65; plot range = 7.40-11.60
  october  mean = 7.61; plot range = 6.40-10.25
```

**Test 3: Independent check of the CSV.** The same summary is recalculated outside the script:

```bash
Rscript -e 'x <- read.csv("results/pound_hill_plot_richness.csv"); stopifnot(nrow(x) == 12L, all(table(x$Cultivation) == 4L)); print(aggregate(MeanRichness ~ Cultivation, x, mean)); print(aggregate(MeanRichness ~ Cultivation, x, range))'
```

| Treatment | Mean | Range of plot means | Plots in figure |
| --- | --- | --- | --- |
| March | 7.81 | 6.33–10.00 | P3, P5, P7, P10 |
| May | 9.65 | 7.40–11.60 | P2, P4, P9, P12 |
| October | 7.61 | 6.40–10.25 | P1, P6, P8, P11 |

Opening `results/pound_hill_plot_richness.pdf` confirmed that all 12 plot labels and their values agree with the CSV, and that the three lines lie at 7.81, 9.65 and 7.61.

**Interpretation:** See the comments at the end of `code/pound_hill_analysis.R`.

---

### Revisions and checks after feedback — 2026/11/25

- Removed the two abundance outputs from the output table; the script writes only the richness CSV and PDF.
- Replaced the `tidyr::pivot_longer()` description with the base-R method the script uses (`t()` and `rep()`).
- Added a figure check to the script. It re-reads the saved CSV and stops if the plotted points or treatment means differ from it. It was tested by deliberately altering the CSV, the mean line and the plotted points; each change stopped the script with an error.
- Recorded the treatment means and ranges from the CSV and compared them with the figure (Test 3).
- Added comments to the script to explain key decisions.

### AI use

| Date | Tool | What I used it for | How I checked the result |
| --- | --- | --- | --- |
| 20–23 Oct 2026 | ChatGPT | Explaining R error messages and concepts, including why plots, not quadrats, are the replicates (pseudoreplication). | Checked one plot's mean richness by hand. |
| 25 Nov 2026 | Claude | Aligning README section 3.2 with the script after feedback and adding the figure check to `pound_hill_analysis.R`. | Reran the script and compared the printed means with the CSV and the PDF. |