# Results explorer (demo)

`index.html` is a self-contained page with every test case from `runs/20261123_final` built in (112 CryptoAPI-Bench cases, Abdul's 15 files, 3 pilot files). Open it in any browser, no server or setup needed.

What you can change:

- Tool A and tool B: CryptoGuard 2019, CryptoGuard 2019 with refinement off, CryptoGuard 2020, SpotBugs + FindSecBugs.
- Which test cases count: data set, case type, and rule.
- Scoring rules: whether array-length hits from the refinement-off build count as detections, and whether CryptoGuard 2020's alerts at an unknown location get credit.
- Statistics: F-score weight, confidence level, number of bootstrap resamples, random seed.

What it shows: precision, recall and F-score with bootstrap confidence intervals, the confusion matrix for each tool, an exact McNemar test on the misuse cases, recall per rule, and the list of cases where the two tools disagree.

## Opening it

GitHub shows `.html` files as source code, not as a page. To view the explorer, clone the repo (or use Code > Download ZIP on GitHub), then open `demo/index.html` in a browser. Nothing else is needed.

## What the demo shows, and where the evidence is

Each step below uses a preset in the page. The same numbers are in the frozen run `runs/20261123_final/`, so they can be checked without the page.

1. "Main result: 127 cases" preset. CryptoGuard 2020 vs SpotBugs: same precision, recall 86% vs 28%, McNemar p well below 0.001.
   Evidence: `runs/20261123_final/cg2020/scored/summary.md` and `runs/20261123_final/fsb/scored/summary.md` (benchmark), `runs/20261123_final/custom_cg2020/scored/summary.md` and `runs/20261123_final/custom_fsb/scored/summary.md` (Abdul's files), and the combined table in `docs/results.md`.
2. "Ablation" preset. Refinement off catches 6 more cases. Untick "Count array-length hits": only 1 real gain is left and the difference is no longer significant.
   Evidence: `runs/20261123_final/cg2019/scored/per_case.csv` vs `runs/20261123_final/cg2019nr/scored/per_case.csv`, and the refinement section of `docs/results.md`.
3. "Abdul's suite" preset. 12 vs 10 of 13 misuses; with only 15 files the gap is not significant.
   Evidence: `runs/20261123_final/custom_cg2020/scored/per_case.csv` and `custom_tests/spotbugs_custom_report.html`.

Traces for the sanity checks (a positive control and the hard-coded key failure case) are in `runs/20261123_final/sanity/` (`SANITY.md`, `trace_*.log`). `SHA256SUMS` in each run folder lets you check that nothing changed.

`cases.json` is the same data as a separate file, and `explorer.template.html` is the page before the data is inserted. To rebuild after a new run, regenerate `cases.json` and replace `__DATA__` in the template with its contents.
