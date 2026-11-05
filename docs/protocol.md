# Experimental protocol (v2, updated 2026-11-04)

Changes from the October proposal are marked **[changed]**.

## Research question

Does CryptoGuard detect Java cryptographic API misuses with the precision and recall the paper reports, and where — by construction — does it fail? We test the paper's specific claims:

| ID | Claim (paper) | Where | Test |
|---|---|---|---|
| C1 | CryptoGuard: 85 TP / 0 FP / 11 FN on all 112 CryptoAPI-Bench cases | Table 7 | E1 |
| C2 | On the 6 rules all tools share, CryptoGuard is 100% precision and recall, SpotBugs much lower on advanced cases | Table 3 | E1, E3 |
| C3 | Refinement insights (RI-I…RI-V) remove 76–80% of alerts and every removed alert is a false positive | §5.4 | E2 |
| C4 | Remaining misses come from clipping orthogonal calls (depth 1); false alarms come from path insensitivity | §7 | E4 |

## Materials (all pinned in `harness/pins.env`)

- **Benchmark [changed]:** CryptoAPI-Bench commit `734aecb` — the last commit with exactly 112 test files, i.e. the version in the paper. The current repo head (`759622f`) has 171 cases; we keep it for an optional extended run only. Without this pin our numbers would not be comparable to the paper.
- **Ground truth [changed]:** the 112-case version ships no labels, so `harness/ground_truth.py` derives them from the file naming scheme (BB = basic, ABI = inter-procedural, ABS = field-sensitive, ABH = false-positive test, Corrected = secure), with the two secure ABH cases taken from the later `CryptoAPI-Bench_details.xlsx`. Result: 112 cases, 96 positive, 16 secure — same totals as the paper. Per-rule counts match Table 7 on 14 of 16 rules (rules 1 and 3 differ by one case each; see LOG 2026-11-04).
- **CryptoGuard [changed]:** two builds instead of one. CG-2019 (`ccs-submission` branch) approximates the paper's tool; CG-2020 (v04.05.03) is the current release. Comparing them separates "paper claim doesn't reproduce" from "tool changed since the paper".
- **Linter baseline [changed]:** FindSecBugs 1.12.0 on SpotBugs 4.6.0 instead of SpotBugs 3.0.1 via SWAMP (SWAMP is offline). Plain SpotBugs has almost no crypto detectors, so FindSecBugs is the meaningful comparison. This version gap means our SpotBugs numbers are not expected to match the paper's exactly.
- **Environment:** Ubuntu 24.04, OpenJDK 8u504 (benchmark compilation, CG-2019, FindSecBugs, and the rt.jar that both CryptoGuard builds analyse against) and OpenJDK 21 (runs CG-2020, whose Ubuntu-packaged Jackson is Java 17 bytecode).

## Scoring

- **Unit:** (test case, the paper rule that case targets). A case is *detected* if the tool raises ≥1 alert that maps to that rule and is located in a class compiled from that case's file. Tool rule IDs are mapped to the paper's Table 1 numbering in `score.py` (`CG_RULE_MAP`, `FSB_RULE_MAP`).
- TP = misuse case detected; FN = misuse case not detected; FP = secure case flagged for its rule; TN = secure case not flagged. Precision = TP/(TP+FP), Recall = TP/(TP+FN).
- Off-target alerts (another rule fired on the file) are logged in `alerts.csv` but not counted, as in the paper's per-rule tables.
- **Strict location rule [new]:** an alert whose location the tool reports as `UNKNOWN` is not attributed to any case. CG-2020 does this for its TrustManager and HostnameVerifier alerts (a reporting bug), costing it 2 TPs. Lenient count would be 84/96.
- **Known limitation:** this is case-level, not line-level. The paper's Table 3 also counts false positives on misuse cases (alerts on the wrong statement); line-level scoring is Daniel's discrepancy-analysis task.

## Experiments

| ID | What | Owner | Status |
|---|---|---|---|
| **E1** | CG-2019 + CG-2020 on 112 cases; per-rule and per-category P/R vs Table 7 and Table 3 | Mark | **Done (baseline run)** |
| **E2** | Refinement ablation: alerts and case outcomes with refinements on vs off | Mark | **Partial**: CG-2019 prints refined-away constants as "Rule Na" blocks, so a lower-bound ablation needs no code change (41.9% of alerts removed on the benchmark; 6 misuse cases would be caught without refinement, 1 secure case would become an FP). Full ablation needs a patched build with the RI checks switched off, because RI-III (bookkeeping indices) is dropped before it reaches the "Na" bucket. |
| **E3** | FindSecBugs on 112 cases + custom suite | Abdelrahman | Baseline run done by the harness; tuning/analysis pending |
| **E4** | Bounded contribution: 15 custom files aimed at §7 failure modes, all three tools | Abdelrahman (files), all (runs) | 3 pilot probes run end-to-end; 12 more planned (see `contribution_plan.md`) |
| **E5** | Map every detection to the threat-model categories; line-level FP/FN discrepancy analysis across tools | Daniel | Pending; inputs are `runs/*/*/scored/alerts.csv` |

## Sanity checks (run by `harness/sanity.sh`, results in `runs/<id>/sanity/SANITY.md`)

| ID | Check | Pass criterion |
|---|---|---|
| S1 | Ground truth vs paper | 112 / 96 / 16 totals; per-rule GTP vs Table 7 |
| S2 | Negative controls | each tool raises no target-rule alert on the 16 secure cases |
| S3 | Positive control | `BrokenHashBBCase2` alone → one MD5 alert |
| S4 | Failure probe | `PredictableCryptographicKeyBBCase1` alone (paper says detected) |
| S5 | Determinism | two CG-2020 runs → identical issue multiset hash |
| S6 | Paper-era agreement | CG-2019 per-rule TP vs Table 7 CryptoGuard column |

## Threats to validity

Derived ground truth (2 per-rule mismatches); CG-2019 is the closest public commit, not necessarily the exact paper binary; CG-2020 runs on JDK 21 rather than 8 (results are deterministic across runs, but we have not yet checked them against a JDK 8 run of CG-2020); FindSecBugs ≠ the paper's SpotBugs 3.0.1; case-level scoring hides wrong-statement alerts.
