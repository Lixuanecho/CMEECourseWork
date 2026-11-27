# CMEE Computing Bootcamp Coursework

**Author:** Lixuan Zhu ([lixuan.zhu26@imperial.ac.uk](mailto\:lixuan.zhu26@imperial.ac.uk))\
**Module:** Biological Computing Bootcamp, CMEE, Imperial College London\
**Repository:** [https://github.com/Lixuanecho/CMEECourseWork](https://github.com/Lixuanecho/CMEECourseWork)\
**Reference:** [MulQuaBio (MQB)](https://mulquabio.github.io/MQB/intro.html)

## Contents

1. [What the project contains](#1-overview-what-the-project-contains)

2. [Software and packages](#2-software-and-packages)

3. [How to run and check each script](#3-how-to-run-and-check-each-script)

4. [Input and output files of each program](#4-input-and-output-files-of-each-program)

5. [Changes after the formative feedback, and how I checked them](#5-changes-after-the-formative-feedback-and-how-i-checked-them)

6. [AI use](#6-ai-use)

7. [Clean clone check](#7-final-check-of-the-whole-portfolio)

---

## 1. Overview: what the project contains

| Part | Topic | Files in `code/` |
| - | - | - |
| Assignment 1 | Process FASTA files with Unix commands; write two delimiter-conversion scripts | `unixPrac1.txt`, `tabtocsv.sh`, `csvtospace.sh` |
| Assignment 2 | Validate and clean the simulated Silwood tree-survey data with Python, and write unit tests | `clean_silwood_trees.py`, `test_silwood_trees.py` |
| Assignment 3 | Calculate tree heights from distances and angles with R, and analyse plant species richness at Pound Hill | `TreeHeight.R`, `get_TreeHeight.R`, `run_get_TreeHeight.sh`, `pound_hill_analysis.R` |
| Assignment 4 | 30 in-class practice scripts | Shell (7): `boilerplate.sh`, `MyExampleScript.sh`, `variables.sh`, `CheckLabel.sh`, `CountLines.sh`, `ConcatenateTwoFiles.sh`, `tiff2_png.sh`<br>Python (12): `boilerplate.py`, `MyExampleScript.py`, `loops.py`, `cfexercises1.py`, `cfexercises2.py`, `control_flow.py`, `test_control_flow.py`, `using_name.py`, `sysargv.py`, `debugme.py`, `observations_practice.py`, `test_observations_practice.py`<br>R (11): `boilerplate.R`, `basic_io.R`, `control_flow.R`, `r_conditionals.R`, `break.R`, `next.R`, `try.R`, `browse.R`, `observations_practice.R`, `data_wrang.R`, `data_wrang_tidy.R` |

### Repository structure

```text
CMEECourseWork/
├── README.md
├── .gitignore        # keeps results/, sandbox/, caches, R session files and Rplots.pdf out of Git
├── Feedback/         # formative feedback: assignment-1-2026.md, assignment-2-2026.md, assignment-3-2026.md
├── code/             # 39 files: the 9 assigned files and the 30 practice scripts listed above
├── data/
│   ├── fasta/                      # 407228326.fasta, 407228412.fasta, e_coli.fasta (A1)
│   ├── temperatures/               # 1800.csv – 1803.csv (A1)
│   ├── tab-example.tsv             # my own small test file with an empty field (A1)
│   ├── silwood_trees_raw.csv       # raw tree survey, 36 records (A2)
│   ├── silwood_trees_metadata.md   # validation rules for the survey (A2)
│   ├── trees.csv                   # tree distances and angles, 120 records (A3, basic_io.R)
│   ├── pound_hill_data.csv         # species counts (A3, data_wrang*.R)
│   ├── pound_hill_meta_data.csv    # metadata for the Pound Hill data
│   └── bootcamp_observations.csv, bootcamp_observations_boundary.csv, bootcamp_observations_invalid.csv
│                                   # ordinary, boundary and invalid observation records (A4)
├── results/          # generated outputs, Git-ignored
└── sandbox/          # Git-ignored
```

---

## 2. Software and packages

| Software | Version I used | Needed for |
| - | - | - |
| Bash | 5.3.9 | All `.sh` scripts and the check commands; also uses `wc`, `tail`, `tr`, `grep`, `awk`, `sed`, `cat`, `cmp`, `file` |
| Python | 3.14.4 | All `.py` scripts |
| R | 4.5.2 | All `.R` scripts |
| R packages `reshape2`, `dplyr`, `tidyr` | latest (CRAN) | `data_wrang.R` (`reshape2`); `data_wrang_tidy.R` (`dplyr`, `tidyr`) |
| ImageMagick | 7.1.2 | `tiff2_png.sh`, which uses `magick` (version 7) or falls back to `convert` (version 6) |
| Git | any | Cloning the repository |

### Installation

```r
install.packages(c("reshape2", "dplyr", "tidyr"))   # in R
```

```bash
brew install imagemagick          # macOS (ImageMagick 7)
sudo apt install imagemagick      # Ubuntu (ImageMagick 6)
```

## 3. How to run and check each script

- Run all commands from the project root. Scripts save output files to results/ and create it if needed.
- Expected outputs appear in comments beside the commands. Intentional errors are marked.
- Commands that import other scripts use python3 -B to avoid creating __pycache__/.

## 3.1 Assignment 1 — UNIX and Bash

#### `unixPrac1.txt`

`code/unixPrac1.txt` holds the commands, answers and explanations for the five FASTA exercises. It is a record, not a script. The commands use `../data/…` paths, so this loop runs them one by one from `code/` and prints the last line of each output.

```bash
(cd code && grep -v -e '^#' -e '^[[:space:]]*$' unixPrac1.txt |
  while IFS= read -r cmd; do printf '$ %s\n' "$cmd"; sh -c "$cmd" | tail -n 1; done)
```

The third column rechecks each answer with a different method. Its output should match the second column.

| Question | Answer printed | Test example (independent check) |
| - | - | - |
| 1. Total lines in the three FASTA files | `78258 total` | `python3 -c 'import glob; print(sum(open(f).read().count("\n") for f in glob.glob("data/fasta/*.fasta")))'` → `78258` |
| 2. *E. coli* sequence without the header | The sequence; last line `CTTAGTAAGTATTTTTC` | `tail -n 1 data/fasta/e_coli.fasta` → `CTTAGTAAGTATTTTTC` |
| 3. Sequence length | `4686137` | `python3 -c 's = "".join(open("data/fasta/e_coli.fasta").read().splitlines()[1:]).upper(); print(len(s))'` → `4686137` |
| 4. Count of `ATGC` | `21968` | `python3 -c 's = "".join(open("data/fasta/e_coli.fasta").read().splitlines()[1:]).upper(); print(s.count("ATGC"))'` → `21968` |
| 5. AT/GC ratio | `0.969228` | `python3 -c 's = "".join(open("data/fasta/e_coli.fasta").read().splitlines()[1:]).upper(); print(round((s.count("A") + s.count("T")) / (s.count("G") + s.count("C")), 6))'` → `0.969228` |
| Ambiguity codes | Only one `R` and one `Y`. Counted in the length (Q3), left out of the ratio (Q5) | `python3 -c 'import collections; s = "".join(open("data/fasta/e_coli.fasta").read().splitlines()[1:]).upper(); print(collections.Counter(c for c in s if c not in "ACGT"))'` → `Counter({'R': 1, 'Y': 1})` |

#### `tabtocsv.sh`

Replaces tabs with commas and writes `results/<file name>.csv`. The checks compare the output with hand-written text.

```bash
bash code/tabtocsv.sh data/tab-example.tsv          # creates results/tab-example.tsv.csv
bash -n code/tabtocsv.sh && echo "syntax OK"
printf 'a,b,c\n1,2,3\n4,,6\n' | cmp - results/tab-example.tsv.csv && echo PASS   # row 3 has an empty middle field
bash code/tabtocsv.sh data/tab-example.tsv > /dev/null
wc -l < results/tab-example.tsv.csv                  # rerun: still 3, the file is replaced, not appended to
bash code/tabtocsv.sh; echo "exit status: $?"                    # Error: Exactly one input file is required. (and usage); exit status: 1
bash code/tabtocsv.sh data/missing.tsv; echo "exit status: $?"   # Error: Input file 'data/missing.tsv' does not exist ...; exit status: 1
```

The last two inputs are invalid. Each prints an error to stderr and exits with status 1.

#### `csvtospace.sh`

Replaces commas with spaces and writes `results/<file name>.txt`. Again, the checks do not reuse `tr`.

```bash
bash code/csvtospace.sh data/temperatures/1800.csv  # creates results/1800.csv.txt
for file in data/temperatures/*.csv; do bash code/csvtospace.sh "$file"; done   # all four temperature files
bash -n code/csvtospace.sh && echo "syntax OK"
[ "$(head -n 1 results/1800.csv.txt)" = 'EZE00100082 18000101 TMAX -86   E ' ] && echo PASS
grep -c ',' results/1800.csv.txt                     # Expected: 0 (no comma left)
awk -F'[ ]' 'NF != 8' results/1800.csv.txt | wc -l   # Expected: 0 (every line keeps its 8 fields)
wc -l < results/1800.csv.txt                         # Expected: 1825, as in the input
bash code/csvtospace.sh                              # Error: Please provide exactly one CSV file.
bash code/csvtospace.sh data/missing.csv             # Error: File 'data/missing.csv' not found or unreadable.
```

The last two inputs are invalid. Each prints an error to stderr and exits with status 1.

The temperature files have empty fields (`EZE00100082,18000101,TMAX,-86,,,E,`), which become runs of spaces. Splitting on any run of whitespace would lose them, so the check uses `awk -F'[ ]'` to split on single spaces. This is a limit of the space-separated format itself.
## 3.2 Assignment 2 — Silwood tree survey

`clean_silwood_trees.py` checks and cleans the 36 simulated records in `data/silwood_trees_raw.csv`, using the rules in the course metadata (`data/silwood_trees_metadata.md`). It does not fix spelling or guess missing values. A record that breaks any rule is rejected, with every reason listed. It writes three files:

- `results/silwood_trees_clean.csv`: the accepted records, tidied and sorted by record ID.
- `results/silwood_tree_issues.csv`: for each rejected record, its line number in the input file, its record ID and its rejection reasons, in the required order.
- `results/oak_species_counts.csv`: the number of accepted `Quercus` records per species, sorted by species name.

`main()` calls `load_records()`, which checks the header and returns each record with its line number. `process_records()` runs `validate_record()` on each record and splits the accepted records from the rejected ones. `summarise_oaks()` only gets the accepted records, so rejected records never count towards the oak totals. Finally, `write_csv()` writes the three files.

**Pseudocode — `clean_silwood_trees.py`**

```text
Read the CSV and verify its header.
Keep each record's line number in the file (reader.line_num, so blank lines are counted).
Initialise accepted records, issues, and accepted IDs.
For each record, in file order:
    Trim text; validate fields against the metadata rules
    (numbers must be plain ASCII number text, so "1_0" or non-ASCII digits are invalid).
    Collect all rejection reasons in the required order.
    If invalid: record its line number, ID and reasons.
    Otherwise: store the canonical record (numbers as decimal text) and reserve its ID.
Sort accepted records by ID.
Count accepted Quercus records by species; sort species names.
Replace the three output CSV files.
If the input is missing or its header is wrong: print one error line and exit with status 1, writing nothing.
```

```bash
python3 -B code/clean_silwood_trees.py
python3 -B code/test_silwood_trees.py       # Expected: Ran 28 tests ... OK
wc -l results/silwood_trees_clean.csv results/silwood_tree_issues.csv   # 25 and 13: 24 accepted, 12 rejected, plus a header each
cat results/oak_species_counts.csv          # Expected: petraea,4 and robur,4
mkdir -p sandbox && cp results/silwood_trees_clean.csv results/silwood_tree_issues.csv results/oak_species_counts.csv sandbox/
python3 -B code/clean_silwood_trees.py      # rerun
for f in silwood_trees_clean.csv silwood_tree_issues.csv oak_species_counts.csv; do cmp "sandbox/$f" "results/$f" && echo "$f identical after rerun"; done
git status --short data/                    # Expected: no output (the supplied inputs are unchanged)
tmp=$(mktemp -d) && mkdir "$tmp/code" && cp code/clean_silwood_trees.py "$tmp/code/"
python3 -B "$tmp/code/clean_silwood_trees.py"; echo "exit status: $?"   # Error: Input file not found: data/silwood_trees_raw.csv; exit status: 1
rm -rf "$tmp"
```

**Results on the supplied data.** Of the 36 records, 24 are accepted and 12 are rejected. The accepted oaks are 4 *petraea* and 4 *robur*. The 12 rejected records cover every kind of problem listed in the metadata. For example, line 26 of the source file has no ID, and line 37 breaks five rules at once (`invalid location; missing genus; missing species; invalid distance_m; missing angle_degrees`).

**Unit tests.** `test_silwood_trees.py` uses Python's `unittest`. All 28 tests pass:

```bash
python3 -B code/test_silwood_trees.py       # Ran 28 tests ... OK
```

| Test | What I did | Result |
| - | - | - |
| Validation rules | Fed in missing, invalid and non-finite values, duplicate IDs and boundary values (0 and 100 m, 0° and 90°) | Each bad value is rejected with the right reason, text is cleaned up, and reasons appear in the required order |
| Records affecting each other | Passed one valid and one invalid record through `process_records()` and `summarise_oaks()` | The rejected record does not take up its ID; neither the invalid oak nor the near-miss genus `Quercuss` is counted |
| Line numbers | Added blank lines to the input | `source_row` still gives the real line number (the `csv` module skips blank lines, so counting records would be wrong) |
| Number formats | Fed in `1_0`, Arabic-Indic digits, full-width digits, `0x10` and `1e999` (some of which `float()` accepts), and a very small distance `0.0000001` | All odd formats are rejected; the small distance is written as decimal text, not `1e-07` |
| Stable output | Ran the cleaner twice and imported the module | Identical files, sorted by record ID, with correct oak counts; the raw CSV is unchanged; importing creates no files |
| Missing input | Ran the cleaner in a folder without `data/` | Prints `Input file not found`, exits with status 1, shows no traceback and creates no output folder |

## 3.3 Assignment 3 — R practicals

### 3.3.1 Tree heights

Both scripts calculate tree height as `height_m = Distance.m × tan(Angle.degrees × π / 180)`. They write four columns, `Species,Distance.m,Angle.degrees,height_m`, and keep the input row order.

| | `TreeHeight.R` | `get_TreeHeight.R` |
| - | - | - |
| Input | Always `data/trees.csv` (exactly 120 data rows) | Any CSV in the same format, given on the command line (at least 1 data row) |
| Output | `results/TreeHts.csv` | `results/<input file name>_treeheights.csv` |

Both scripts reject wrong column names, non-finite numbers, a `Distance.m` outside (0, 100] m and an `Angle.degrees` outside (0, 90)°, and name the bad rows (for example `Invalid data row(s): 4`). They write results only after every check passes, so bad input never creates or overwrites a result. Each script keeps its own `TreeHeight()` and checks, because loading `TreeHeight.R` would run the whole script and rewrite its results (see Section 5).

```bash
Rscript code/TreeHeight.R                      # prints [1] 30.14216, the example TreeHeight(37, 40)
Rscript code/get_TreeHeight.R data/trees.csv
bash code/run_get_TreeHeight.sh                # runs get_TreeHeight.R on data/trees.csv and checks the 120 data rows
```

| Test | What I did | Result |
| - | - | - |
| Rows and header | Checked both outputs with `wc -l` and `head -n 1`, then ran again | 121 lines each (header + 120 records), unchanged after the rerun |
| Row order | Compared the first three output columns with the input | Identical |
| Both scripts agree | `diff results/TreeHts.csv results/trees_treeheights.csv` | Same file |
| Known answer | Test file with distance 8 m and angle 45° | `height_m` = 8 |
| Hand check | Record 4 (*Fraxinus excelsior*, 34.6166691975668 m, 23.336126555223°): calculator in degree mode gives tan = 0.431416, height 14.934 m | Script gives 14.934175 m, within 0.001 m |
| Bad measurement (fixed input) | Made record 4's distance negative in a temporary copy | `Invalid data row(s): 4`; old result not overwritten; original `data/trees.csv` unchanged |
| Bad measurement (any input) | Test file with a distance of −5 in row 2 | `Invalid data row(s): 2`; no result written |
| Bad arguments and files | No argument, two arguments, missing file, wrong column names | Usage message or a clear error, then stops |
| `browser()` debugging | Added a temporary `browser()` before the height line, started R with `R --vanilla --args data/trees.csv`, ran `source("code/get_TreeHeight.R")` and inspected record 4 | `trees$height_m[4]` matched the hand-calculated 14.934 m |

<details>
<summary>Commands to reproduce these tests</summary>

```bash
head -n 1 results/TreeHts.csv      # "Species","Distance.m","Angle.degrees","height_m"
wc -l results/TreeHts.csv results/trees_treeheights.csv   # 121 each
Rscript -e 'a <- read.csv("data/trees.csv"); b <- read.csv("results/TreeHts.csv"); stopifnot(isTRUE(all.equal(a, b[1:3]))); cat("PASS\n")'
diff results/TreeHts.csv results/trees_treeheights.csv && echo SAME
sed -n 5p results/TreeHts.csv      # record 4, checked by hand

mkdir -p sandbox
printf 'Species,Distance.m,Angle.degrees\nTest,8,45\n' > sandbox/tree_test.csv
Rscript code/get_TreeHeight.R sandbox/tree_test.csv && cat results/tree_test_treeheights.csv   # height_m = 8
printf 'Species,Distance.m,Angle.degrees\nTest,8,45\nTest,-5,30\n' > sandbox/bad_distance.csv
rm -f results/bad_distance_treeheights.csv
Rscript code/get_TreeHeight.R sandbox/bad_distance.csv    # ... Invalid data row(s): 2
test -e results/bad_distance_treeheights.csv || echo "No result written"
Rscript code/get_TreeHeight.R                             # usage message
Rscript code/get_TreeHeight.R data/missing.csv            # input file does not exist
printf 'Name,Distance.m,Angle.degrees\nTest,8,45\n' > sandbox/bad_header.csv
Rscript code/get_TreeHeight.R sandbox/bad_header.csv      # CSV must contain exactly: ...

# Fixed-input script: run in a temporary copy so data/trees.csv is never changed
tmp=$(mktemp -d) && cp -R code data "$tmp"
(
  cd "$tmp" || exit 1
  Rscript code/TreeHeight.R > /dev/null
  cp results/TreeHts.csv TreeHts_before.csv
  sed '5s/,34.6166691975668,/,-34.6166691975668,/' data/trees.csv > trees_edited.csv
  mv trees_edited.csv data/trees.csv
  Rscript code/TreeHeight.R                    # Distance.m must be finite with 0 < distance <= 100. Invalid data row(s): 4
  cmp TreeHts_before.csv results/TreeHts.csv && echo "Result not overwritten"
)
rm -rf "$tmp"
git status --short data/                       # no output
```

</details>
```

### 3.3.2 Cultivation timing and plant species richness at Pound Hill

> **Research question:** How does mean plant species richness per quadrat differ between cultivation in March, May and October?

`pound_hill_analysis.R` uses base R only. The blocked analysis is printed to the terminal, not saved.

| | File | Contents |
| - | - | - |
| Input | `data/pound_hill_data.csv`, `data/pound_hill_meta_data.csv` | Species counts and metadata |
| Output | `results/pound_hill_plot_richness.csv` | Mean species richness of the 12 plots (`Cultivation`, `Block`, `Plot`, `MeanRichness`) |
| Output | `results/pound_hill_plot_richness.pdf` | One labelled point per plot, one mean line per treatment, grey lines joining the plots of each block |

```bash
Rscript code/pound_hill_analysis.R
```

**Method**

1. **Tidy the data.** Transpose the raw table and reshape it into long format with `rep()`. The metadata say a blank count means the species was absent, so blanks become 0. All counts must then be finite, non-negative whole numbers.
2. **Calculate richness.** Each quadrat is identified by `Cultivation`, `Block`, `Plot` and `Quadrat`. Count the species with `Count > 0` in each quadrat, then average the quadrats within each plot. Plots have 3–6 quadrats, so using plot means gives each treatment's four plots equal weight.
3. **Compare treatments within blocks.** Each of the four blocks (a–d) has one plot per treatment, so `lm(MeanRichness ~ Cultivation + Block)` analyses the 12 plot means without mistaking block differences for treatment effects. A Friedman test on the ranks within blocks backs this up.

| Check | What I did | Result |
| - | - | - |
| Data validation (built in) | The script checks count formats, quadrat IDs and the block design, and stops if any check fails | 41 species, 59 quadrats, 2,419 long-format rows (59 × 41), 12 plots, one plot per treatment in each block |
| Figure matches CSV (built in) | The script re-reads the saved CSV and checks every point and mean line in the figure | `Figure check passed: 12 points and 3 treatment means match the CSV.` |
| Independent recalculation | Recalculated each treatment's mean and range outside the script with `aggregate()` | Matches the table below |
| Friedman by hand | Ranked plots within each block (1 = lowest): May ranks 3rd in all four blocks (rank sum 12); March and October both sum to 6; χ² = 12/48 × (12² + 6² + 6²) − 48 | χ² = 6.0, same as the script |
| Figure by eye | Opened the PDF and compared it with the CSV | All 12 labels and values and the three mean lines match; each block's line peaks at May |

**Results**

| Treatment | Mean ± SE (model) | Range of plot means | Plots in figure |
| - | - | - | - |
| March | 7.81 ± 0.84 | 6.33–10.00 | P3, P5, P7, P10 |
| May | 9.65 ± 0.84 | 7.40–11.60 | P2, P4, P9, P12 |
| October | 7.61 ± 0.84 | 6.40–10.25 | P1, P6, P8, P11 |

Blocked analysis: Cultivation F(2, 6) = 1.77, p = 0.248; Block F(3, 6) = 1.41, p = 0.330; standard error of a difference between two treatment means = 1.19; Friedman χ² = 6.0, df = 2, p = 0.050.

**Interpretation** (full discussion in the comments at the end of `code/pound_hill_analysis.R`)

- May cultivation gives the highest species richness, and May is highest in all four blocks.
- But the blocked analysis finds no significant treatment effect (p = 0.25). May has about two more species, which is less than twice the standard error of the difference (1.19), so the evidence is weak.
- If cultivation months were assigned to plots at random within blocks, the difference could be put down to cultivation timing. The metadata do not say how they were assigned, so this needs checking. The main limitation is low replication: four plots per treatment gives little power.

<details>
<summary>Commands to reproduce the independent checks</summary>

```bash
Rscript -e 'x <- read.csv("results/pound_hill_plot_richness.csv"); stopifnot(nrow(x) == 12L, all(table(x$Cultivation) == 4L)); print(aggregate(MeanRichness ~ Cultivation, x, mean)); print(aggregate(MeanRichness ~ Cultivation, x, range))'
Rscript -e 'x <- read.csv("results/pound_hill_plot_richness.csv"); r <- t(sapply(split(x, x$Block), function(b) rank(b$MeanRichness[match(c("march", "may", "october"), b$Cultivation)]))); colnames(r) <- c("march", "may", "october"); print(r); print(colSums(r))'
```

</details>

## 4. Input and output files of each program

- All paths are relative to the project root. 
- “Prints only” means the script writes to the terminal without saving a file.

| File | Reads | Creates |
| - | - | - |
| **Assignment 1** | | |
| `unixPrac1.txt` | `407228326.fasta`, `407228412.fasta` and `e_coli.fasta` in `data/fasta/` | Prints only |
| `tabtocsv.sh` | A tab-separated file, e.g. `data/tab-example.tsv` | `results/<file name>.csv`, e.g. `results/tab-example.tsv.csv` |
| `csvtospace.sh` | A comma-separated file, e.g. `data/temperatures/1800.csv` | `results/<file name>.txt`, e.g. `results/1800.csv.txt` |
| **Assignment 2** | | |
| `clean_silwood_trees.py` | `data/silwood_trees_raw.csv` (see `data/silwood_trees_metadata.md` for validation rules) | `results/silwood_trees_clean.csv`, `results/silwood_tree_issues.csv`, `results/oak_species_counts.csv` |
| `test_silwood_trees.py` | Test records created in a temporary directory | Temporary files only, removed after testing |
| **Assignment 3** | | |
| `TreeHeight.R` | `data/trees.csv` | `results/TreeHts.csv` |
| `get_TreeHeight.R` | A CSV file passed as an argument, e.g. `data/trees.csv` | `results/<input name>_treeheights.csv` |
| `run_get_TreeHeight.sh` | `data/trees.csv` via `get_TreeHeight.R` | `results/trees_treeheights.csv` |
| `pound_hill_analysis.R` | `data/pound_hill_data.csv`, `data/pound_hill_meta_data.csv` | `results/pound_hill_plot_richness.csv`, `results/pound_hill_plot_richness.pdf` (block analysis results are printed only) |

---



## 5. Changes after the formative feedback, and how I checked them

- Each row pairs a point from `Feedback/` with the change (commit) and its check. 
- I re-ran all checks from the root of a fresh `git clone` (FASTA commands from `code/`).

### Assignment 1 — UNIX and Bash

Feedback: `Feedback/assignment-1-2026.md` (assessed snapshot `18f27a3`)

| Feedback | Change (commit) | Check |
| --- | --- | --- |
| Explain the method for Q2–Q5, not only the result. | Explained each step and result for Q2–Q5 in `unixPrac1.txt`, including why lines are joined before motif counting and why ambiguity codes count towards length but not the AT/GC ratio (`11abfbc`). | All five results are unchanged (78258; 4686137; 21968; 0.969228). Unjoined lines give 20853 `ATGC` matches, missing 1115 that span line breaks. Only two ambiguity codes occur (one R, one Y). |
| Run the converters from the repository root, not `code/`. | Both scripts now write to `results/` when run from the root; `tabtocsv.sh` uses `#!/bin/sh`, like `csvtospace.sh`. Updated the README examples, adding a loop over the four temperature files (`11abfbc`, `4146a69`). | In a fresh clone, the README commands create `results/`, and all five outputs match a direct `tr` substitution (`cmp`). Both scripts pass `bash -n` and `dash -n`. |
| Provide `data/tab-example.tsv` with an empty field; record output checks, not only syntax checks. | Added the TSV (`c4f32a0`) and `cmp` output checks to the README (`4146a69`). | The output ends with `4,,6`; the empty field is preserved. |
| Ignore results; keep generated and disposable files out of the repository. | Ignored `/results/` and `/sandbox/` (`a5dd442`), then editor, Python-cache and R-session files (`11abfbc`, `4146a69`). Untracked `sandbox/` (`c4f32a0`) and later added revised classroom scripts to `code/` (`95ab125`, `bf6ac2f`, `e239810`). | `git ls-files results sandbox` returns nothing; `git status` stays clean after all scripts have run. |
| Document any help used. | Added an AI-use note to each assignment (`11abfbc`, `4146a69`). | – |

### Assignment 2 — Silwood tree survey

Feedback: `Feedback/assignment-2-2026.md` (assessed snapshot `9c88a8f`)

| Feedback | Change (commit) | Check |
| --- | --- | --- |
| Restore the supplied `silwood_trees_metadata.md`. | Restored it (`4146a69`). | `cmp` finds it identical to the course copy (MulQuaBio/MQB, `content/data/`). `silwood_trees_raw.csv` also matches and has never been edited. |
| Test one valid and one invalid record through `process_records()` and `summarise_oaks()`. | Added `test_rejected_oak_excluded_from_summary`: two *Quercus robur* records, one with `distance_m = 0`; it checks the cleaned list, the issue row and a robur count of 1. Added `test_oak_near_match_rejected`: genus `Quercuss` is rejected and not counted (`3d7cbbd`). | `Ran 23 tests ... OK` (previously 21). |
| Document what the cleaner does, its root-level commands and its three outputs; test the commands in a fresh clone. | Rewrote the section: input/output table, workflow pseudocode, test notes and root-level commands (`4146a69`). | Both commands run unmodified in a fresh clone. The cleaner writes the three outputs: 24 accepted and 12 rejected rows from 36 records, and oak counts of petraea 4 and robur 4. `data/` is unchanged. |

### Assignment 3 — R practicals

Feedback: `Feedback/assignment-3-2026.md` (assessed snapshot `4146a69`)

| Feedback | Change (commit) | Check |
| --- | --- | --- |
| Check record 4 independently of the program's formula. | README Test 5 now reports a degree-mode calculator check with inputs, units and agreement (`0637457`). | 34.6166691975668 m × tan(23.336126555223°) = 34.6166691975668 × 0.431416 = 14.934 m; the script gives 14.934175 m (difference < 0.001 m). |
| Isolate the fixed-route invalid test, which failed on row count ("Expected 120 tree records") rather than on the bad measurement. | Errors in both scripts now name the failing rows. README Test 6 keeps all 120 rows and columns, negates only record 4's distance and then restores the file (`0637457`). | The run stops with `Distance.m must be finite with 0 < distance <= 100. Invalid data row(s): 4`. `md5sum -c` shows the existing result is not overwritten; with no prior result, none is created. `get_TreeHeight.R` Test 4 reports `Invalid data row(s): 2` and writes no file. |
| Make section 3.2 match the script (the README cited `tidyr::pivot_longer()` and abundance outputs). | Section 3.2 now describes the base-R route (`t()`, `rep()`) and lists only the richness CSV and PDF (`c776b03`). | The script uses base R only; a fresh run writes only these two files. |
| Compare the plotted points and means with the CSV. | Added a figure check that re-reads the saved CSV and stops if any of the 12 points or 3 mean lines differ (`c776b03`). | The check passes on a fresh run (means: March 7.81, May 9.65, October 7.61), and Test 3 reproduces these with `aggregate()`. Altering the CSV, one point or one mean line in a copy of the script raised an error in each case. The PDF shows the same 12 labels and 3 lines. |
| Use comments to explain decisions; avoid repeated calculations. | Added headers and decision comments to the three R scripts and defined `months` once in `pound_hill_analysis.R`. Kept `TreeHeight()` in both tree-height scripts, since sourcing `TreeHeight.R` would rerun it and overwrite its output. Dropped `quote = FALSE` from `TreeHeight.R`, so both scripts write identical CSVs (`0637457`, `c776b03`). | `diff` finds `results/TreeHts.csv` and `results/trees_treeheights.csv` identical (at `4146a69` they differed in quoting). |

I made two commits for the Assignment 3 revisions. The first covered tree height and Section 3.1 (22 November 2026, 0637457), and the second covered Pound Hill and Section 3.2 (25 November 2026, c776b03).

## 6. AI use
| Date | Tool | What I used it for | How I checked the result |
| --- | --- | --- | --- |
| 8–9 Oct 2026 | ChatGPT | Tutoring on Python syntax and rules (Assignment 1). | Checked against the MQB notes and by running the code. |
| 16 Oct 2026 | ChatGPT | Tutoring on handling error messages, testing inputs and wording the README (Assignment 2). | Checked against the MQB notes and by running the code. |
| 20–23 Oct 2026 | ChatGPT | Explaining R error messages and concepts, including why plots, not quadrats within a plot, are the independent replicates, and why treating quadrats as replicates is pseudoreplication. | Calculated one plot's mean species richness by hand. |
| 20–27 Nov 2026 | ChatGPT | I used ChatGPT for step-by-step explanations of shell commands, R, command-line checks and interactive debugging, and I used Codex to help me adapt classroom examples, run checks, record results and understand how to verify the tree-height diagnostics and the Pound Hill figure against the raw data. | Ran the relevant scripts and checks locally and compared the outputs with the expected results. |

---

## 7. Clean-Clone Check
