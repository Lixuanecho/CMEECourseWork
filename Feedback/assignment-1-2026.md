# Assignment 1 feedback - Lixuan Zhu

**Formative feedback | Rubric 2026.2**

All five Unix answers produced the requested outputs in the independent checks. The converters also have readable argument and file checks and report success only after conversion succeeds. Your README provides a useful map, example commands and syntax checks.

The Unix explanations need a little more attention. For Q2-Q5, a result value is not a substitute for explaining the method. Add a short account of what each stage does and what the final number represents. Why must sequence lines be joined for motif counting? Why are ambiguity symbols included in length but not assigned to a base in the ratio? Keep the explanation short, but make the reasoning visible.

Both converters assume code/ as their starting directory because they write through ../results. Align them and their README examples with the required repository-root invocation, then check outputs from a fresh checkout. The CSV script's use of portable sh syntax is not itself a problem; there is no need to change languages just for appearance.

Supply your own data/tab-example.tsv, include an empty field and record actual output checks rather than only syntax-check commands. Add a results ignore rule, retain the useful task-specific commits and document any help used. A .gitkeep placeholder is fine, but generated conversion files should not be part of the submission.

---

## Project structure

Relevant tracked layout (simplified; missing required paths are marked):

```text
README.md
.gitignore
code/  unixPrac1.txt, tabtocsv.sh, csvtospace.sh
data/fasta/  3 required files present
data/temperatures/  4 required files present
data/tab-example.tsv [missing]
results/  placeholder only
sandbox/  18 files tracked
```

The assessed code and supplied inputs are in their required locations, but the own TSV is missing. results/ contains only a placeholder. Sandbox contains tracked classroom scripts alongside test files, while the root ignore file does not exclude results or disposable sandbox contents.

Add the TSV and sort the sandbox contents by purpose. Preserve durable classroom scripts in code/ or a clearly documented classwork subdirectory; untrack genuinely disposable tests. Add the appropriate ignore rules and keep README.md as the guide to the assessed files. A blanket cleanup should not throw away useful teaching work.

**Assessed snapshot:** `18f27a3da04d907a87949f5403d275b76b629dd9`
