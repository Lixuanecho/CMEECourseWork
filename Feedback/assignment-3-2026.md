# Assignment 3 formative feedback

This feedback is organised using the [Computing Bootcamp rubric](https://mulquabio.github.io/MQB/rubrics/Computing_Bootcamp_Rubric.html). It does not award a mark; use it to decide what to revise and check before final submission.

## Criterion 1: Repository organisation & workflow discipline

- Required paths are present, generated results are not tracked, and `.gitignore` covers results, temporary experiments and R session files. The commits have descriptive, task-focused messages. Your README provides useful run commands and test examples.

## Criterion 2: Code completeness & functional correctness

- Both the fixed and generalised tree-height programs ran successfully in the checks run for this feedback. Their respective CSV outputs satisfied the tree-height required output format and values; the Pound Hill richness table also had the expected rows, plot identifiers and richness values. These are separate pieces of evidence, rather than success in one route establishing the other.

## Criterion 3: Code quality & style

As you revise, keep names descriptive, use comments to explain decisions rather than restating code, and avoid repeating the same calculation in several places.

## Criterion 4: Documentation

- Before final submission, **Strengthen the independent height check.** Your README supplies a fourth-record check, but it repeats the same formula used by the program; execution of that documented check was not collected here. Compare that record with a separate calculator calculation, recording the inputs, units and agreement. This helps explain why the output is plausible, beyond confirming that the same expression gives the same result.

## Criterion 5: Version-control practice

Commit each functional revision with a short message that says what changed; this makes your development easier to follow than one large final commit.

## Criterion 8: Basic error-handling & input validation

- Before final submission, **Isolate the fixed-route measurement validation test.** The fixed invalid-input run stopped with “Expected 120 tree records”, so it demonstrated rejection but did not establish that the bad measurement triggered its intended check. The generalised run instead reported an invalid distance. For the fixed route, retain the expected columns and record count and alter just one measurement. Check that the error identifies that measurement and that no result is newly written or overwritten. This is a testing-evidence gap, not a demonstrated failure of the code validation.

## Criterion 9: Problem-solving approach & method implementation

- Your code connects measurements to results clearly: tree angles are converted from degrees to radians, while the Pound Hill analysis distinguishes richness from abundance and averages quadrats within plots before comparing treatments. Comments explain why blank counts become zero for this dataset and why plots are the replicates. Your interpretation acknowledges within-treatment variation and avoids claiming causation from descriptive patterns.
- Although the automated check only confirmed that the PDF existed, opening the figure showed the figure particularly clear, with individual plot labels, treatment means, an explanatory caption and informative axes.
- Before final submission, **Make the README agree with the implemented Pound Hill route.** It describes `tidyr::pivot_longer()` and abundance outputs, whereas the inspected script uses base R and writes the richness CSV and PDF only. This could lead a reader to expect dependencies or files that this program does not provide. Update the method and output list to describe what the script actually does; the base-R implementation need not be replaced simply to match the current prose.

## Criterion 10: Learning progression demonstration

Use this feedback as a revision checklist. Make the changes in small, descriptive commits, then add a short README note explaining what you changed and how you checked it. This will make your development from this formative checkpoint visible in the final portfolio.

## Priorities before final submission

- Run commands from the directory containing `code/`, `data/` and the root `README.md`. Rerun one ordinary and one isolated invalid case for each tree-height route, inspecting both the error message and output behaviour. Then regenerate the Pound Hill outputs, compare the plotted points and means with the CSV, and retain the clear labels and cautious biological interpretation. Commit the documentation and test revisions descriptively, keeping generated files ignored.
