# Results explorer (demo)

`index.html` is a self-contained page with every test case from `runs/20261123_final` built in (112 CryptoAPI-Bench cases, Abdul's 15 files, 3 pilot files). Open it in any browser, no server or setup needed.

What you can change:

- Tool A and tool B: CryptoGuard 2019, CryptoGuard 2019 with refinement off, CryptoGuard 2020, SpotBugs + FindSecBugs.
- Which test cases count: data set, case type, and rule.
- Scoring rules: whether array-length hits from the refinement-off build count as detections, and whether CryptoGuard 2020's alerts at an unknown location get credit.
- Statistics: F-score weight, confidence level, number of bootstrap resamples, random seed.

What it shows: precision, recall and F-score with bootstrap confidence intervals, the confusion matrix for each tool, an exact McNemar test on the misuse cases, recall per rule, and the list of cases where the two tools disagree.

Demo path for the talk:

1. "Slide 6: 127 cases" preset. CryptoGuard 2020 vs SpotBugs: same precision, recall 86% vs 28%, McNemar p well below 0.001.
2. "Ablation" preset. Refinement off catches 6 more cases. Untick "Count array-length hits": only 1 real gain is left and the difference is no longer significant.
3. "Abdul's suite" preset. 12 vs 10 of 13 misuses; with only 15 files the gap is not significant.

`cases.json` is the same data as a separate file, and `explorer.template.html` is the page before the data is inserted. To rebuild after a new run, regenerate `cases.json` and replace `__DATA__` in the template with its contents.
