# Assignment 2 formative feedback

This feedback is organised by the relevant computing bootcamp criteria. Use it to decide what is already working, what you need to investigate, and what to revise before the cumulative submission.

The full criteria are in the [Computing Bootcamp assessment rubric](https://github.com/MulQuaBio/MQB/blob/main/content/rubrics/Computing_Bootcamp_Rubric.md).

## 1. Repository organisation and workflow discipline

- The required files are in the expected locations and the raw CSV is unchanged, but `data/silwood_trees_metadata.md` differs from the supplied original. Compare the two files and restore the supplied version if the change was unintended; keep your own notes elsewhere.

## 2. Code completeness and functional correctness

- Your cleaning script ran and generated the required files. Separately, output checks reported that the cleaned records, issues and oak-count tables satisfied their required output format and contents on both test runs. The outputs are correct for the checked input; now make sure you can explain how the program produces them.

## 3. Code quality and style

- Your `main()` function gives the program a clear overall structure by connecting loading, processing, summarising and writing. Keep these stages distinct as you revise; use descriptive names and add short comments where the reason for a validation check or data-cleaning step is not obvious.

## 4. Documentation

- Your root README is in place. Make it useful to someone opening the repository for the first time: explain what the cleaner does, how to run the script and tests from the repository root, and which three files it creates. Test the instructions in a newly cloned copy of your repository (a separate folder created with `git clone`): enter that folder and run each README command exactly as written. If something fails, correct the command or add the missing step.

## 5. Version-control practice

- Since the previous formative feedback was added, the saved history contains 8 non-merge commits. Messages such as `Refactor code structure for improved readability and maintainability` and `Update final test py file` identify the kind of revision made, although some commits also combine work from different assignments.
- Before each commit, run `git diff --staged` to see exactly what will be recorded. Keep one coherent, working change per commit and write a concise message that names what changed—for example, the validation rule added, the failing test fixed or the README instruction clarified.

## 8. Basic error handling and input validation

- Your separate test file is present and ran successfully. Your test file includes tests for record validation, accepted/rejected partitioning, oak summaries and end-to-end writing and execution. These exercise several stages of the workflow, although successful execution does not show that every important case is covered.
- Review your existing assertions and add a small focused test only where an expected behaviour is not already checked. Then rerun the separate tests and cleaning workflow.

## 9. Problem-solving approach and method implementation

- Your code shows a connected workflow: `main()` calls `load_records()` to read the unchanged supplied CSV, then `process_records()` uses `validate_record()` to separate rows into `(clean_records, issues)`. The cleaned collection feeds `summarise_oaks()`, and three `write_csv()` calls produce the outputs. The route from input to outputs is clear.
- Before final submission, make this check visible in your repository. In `code/test_silwood_trees.py`, add or refine a small assertion-based test with one valid and one invalid record. Check that `process_records()` places them in the cleaned and issues collections respectively. Then pass the returned cleaned collection to `summarise_oaks()` and check that the invalid record does not contribute. Briefly explain this flow in your root README.
