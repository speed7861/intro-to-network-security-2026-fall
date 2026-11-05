# Experimental protocol (version 2, updated November 4, 2026)

## Research question

Does CryptoGuard find Java crypto API misuses with the precision and recall the paper reports? And where does it fail by design?

We are testing four specific claims from the paper:

| ID | Claim | Where in the paper | Experiment |
|---|---|---|---|
| C1 | On all 112 CryptoAPI-Bench cases, CryptoGuard gets 85 true positives, 0 false positives and 11 false negatives | Table 7 | E1 |
| C2 | On the 6 rules every tool covers, CryptoGuard has 100% precision and recall, and SpotBugs does much worse on the advanced cases | Table 3 | E1, E3 |
| C3 | The refinement insights (RI-I to RI-V) remove 76 to 80 percent of alerts, and every removed alert is a false positive | Section 5.4 | E2 |
| C4 | The remaining misses come from clipping orthogonal method calls at depth 1, and the false alarms come from path insensitivity | Section 7 | E4 |

## Materials

All versions are pinned in `harness/pins.env`.

Benchmark. We use CryptoAPI-Bench commit `734aecb`, which is the last commit with exactly 112 test files, so it is the version the paper used. The current version of the repo has 171 cases. We only use that one for an optional extended run, because results on it can't be compared with the paper.

Ground truth. The 112-case version has no label file, so `harness/ground_truth.py` builds the labels from the file names. BB files are basic cases, ABI files are inter-procedural, ABS files are field-sensitive, ABH files are the paper's "false positive tests", and Corrected files are secure. The two ABH files that are actually secure are taken from the label spreadsheet in the later version. This gives 112 cases, 96 vulnerable and 16 secure, the same totals as the paper. The per-rule counts match the paper on 14 of 16 rules. Rules 1 and 3 are off by one case each (see the log for November 4).

CryptoGuard. We use two builds. CG-2019 is the `ccs-submission` branch and is as close as we can get to the paper's tool. CG-2020 is the current release, v04.05.03. Running both lets us tell whether a difference comes from the paper or from later changes to the tool.

SpotBugs. We use FindSecBugs 1.12.0 on SpotBugs 4.6.0. The paper used SpotBugs 3.0.1 through SWAMP, which is no longer available. Plain SpotBugs has almost no crypto checks, so FindSecBugs is the fair comparison. Because of the version gap, we don't expect our SpotBugs numbers to match the paper exactly.

Compilation. All test cases (benchmark and custom) are compiled with javac to Java 8 bytecode.

Environment. Ubuntu 24.04 with OpenJDK 8u504 and OpenJDK 21. JDK 8 compiles the test cases, runs CG-2019 and FindSecBugs, and provides the Java runtime library that both CryptoGuard versions analyse against. JDK 21 runs CG-2020, because the Jackson library it uses from Ubuntu's packages needs Java 17 or newer.

## How results are scored

Each test case targets one rule from the paper's Table 1. A case counts as detected if the tool raises at least one alert for that rule in a class compiled from that case's file.

- True positive (TP): a vulnerable case that was detected.
- False negative (FN): a vulnerable case that was missed.
- False positive (FP): a secure case that was flagged for its rule.
- True negative (TN): a secure case that was not flagged.

Precision = TP / (TP + FP)

Recall = TP / (TP + FN)

Alerts for a different rule than the one a file targets are saved in `alerts.csv` but not counted, which is how the paper's per-rule tables work too.

If a tool reports an alert without saying which class it is in, we don't credit it to any case. CG-2020 does this for its TrustManager and HostnameVerifier alerts, which costs it 2 detections. Counting those would give 84 of 96.

This scoring works per case, not per line. The paper's Table 3 also counts alerts on the wrong line of a vulnerable file as false positives. Line-level comparison is part of Daniel's discrepancy analysis.

## Experiments

| ID | What | Owner | Status |
|---|---|---|---|
| E1 | Both CryptoGuard versions on the 112 cases, per rule and per category, compared with Tables 7 and 3 | Mark | Done (baseline run) |
| E2 | Refinement ablation: alerts and case results with refinement on and off | Mark | Partly done. CG-2019 lists the alerts it removed, which gives a lower bound: 42 percent of alerts removed, 6 more vulnerable cases would be caught without refinement and 1 secure case would become a false alarm. A full ablation needs a modified build, because RI-III removes alerts before they show up in that list |
| E3 | FindSecBugs on the 112 cases and the custom suite | Abdelrahman | Baseline run done through the harness, analysis to come |
| E4 | Custom test suite of 15 files targeting the failure modes in Section 7, run through all three tools | Abdelrahman writes the files, everyone runs them | 3 pilot files done, 12 to go (see `contribution_plan.md`) |
| E5 | Map every detection to a CWE, then list where the tools disagree, including line-level false positives and false negatives | Daniel | Schema drafted. Inputs are in `runs/*/*/scored/alerts.csv` |

## Sanity checks

S0 is covered by `harness/run_all.sh` (see `fsb/fsb_manifest.txt` in each run). `harness/sanity.sh` runs S1 to S6 and writes the results to `runs/<run>/sanity/SANITY.md`.

| ID | Check | Pass if |
|---|---|---|
| S0 | SpotBugs/FindSecBugs harness validation run | It runs on the benchmark and the custom tests with exit code 0 and writes a report |
| S1 | Ground truth vs the paper | 112 / 96 / 16 totals, per-rule counts compared with Table 7 |
| S2 | Negative controls | No tool flags any of the 16 secure cases for their rule |
| S3 | Positive control | `BrokenHashBBCase2` on its own gives one MD5 alert |
| S4 | Failure probe | Run `PredictableCryptographicKeyBBCase1` on its own (the paper says it is detected) |
| S5 | Determinism | Two runs of CG-2020 give the same set of issues |
| S6 | Agreement with the paper | CG-2019 per-rule detections compared with Table 7 |

## Threats to validity

- Our ground truth is reconstructed from file names and differs from the paper on 2 rules.
- CG-2019 is the closest public commit to the paper, but it may not be the exact build the authors used.
- CG-2020 runs on JDK 21 instead of JDK 8. Its results are the same from run to run, but we haven't compared them with a JDK 8 run yet.
- FindSecBugs 1.12.0 is not the same as the paper's SpotBugs 3.0.1.
- Per-case scoring doesn't catch alerts that point at the wrong line.
