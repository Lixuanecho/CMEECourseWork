# CMEECourseWork Assignment 1

**Author:** Lixuan Zhu  
**Programme:** MSc Computational Methods in Ecology and Evolution  
**Date:** October 2026

## 1. Overview

Coursework for the Biological Computing Bootcamp, covering UNIX commands, FASTA sequence analysis and shell scripting.

## 2. Project Structure

```text
CMEECourseWork/
├── README.md
├── code/
│   ├── unixPrac1.txt
│   ├── tabtocsv.sh
│   └── csvtospace.sh
├── data/
│   └── fasta/
│       ├── 407228326.fasta
│       ├── 407228412.fasta
│       └── e_coli.fasta
├── results/
└── sandbox/
```

- `code/` — Scripts and UNIX exercises.
- `data/` — Input datasets.
- `results/` — Generated outputs.
- `sandbox/` — Temporary files and testing.

## 3. Requirements

- Linux or another UNIX-like environment.
- Bash and standard UNIX utilities (`wc`, `tail`, `tr`, `grep`, `awk`).

## 4. Usage

Run commands from the `code/` directory:

```bash
cd code
```

### FASTA Analysis

`unixPrac1.txt` contains five UNIX exercises covering sequence inspection, length calculation, motif counting and AT/GC ratio analysis.

Example:

```bash
tail -n +2 ../data/fasta/e_coli.fasta | tr -d '\r\n' | wc -c
```

Expected output: `4686137` bases.


### Shell Scripts

`tabtocsv.sh` converts tabs to commas, while `csvtospace.sh` replaces commas with spaces.

Example:

```bash
mkdir -p ../sandbox
printf 'species\tcount\noak\t3\n' > ../sandbox/example.tsv

bash tabtocsv.sh ../sandbox/example.tsv
sh csvtospace.sh ../results/example.tsv.csv
```

Outputs are saved in `results/`. Both scripts validate input files and return an error for invalid arguments.

To check shell syntax:

```bash
bash -n tabtocsv.sh
sh -n csvtospace.sh
```

## 5. Data

FASTA datasets are provided through the MulQuaBio UNIX practical and stored in `data/fasta/`.

Original input files remain unchanged. Generated outputs are stored separately in `results/`.


## References

- [MulQuaBio — UNIX and Linux](https://mulquabio.github.io/MQB/notebooks/unix.html)
- [MulQuaBio — Shell Scripting](https://mulquabio.github.io/MQB/notebooks/shell-scripting.html)
