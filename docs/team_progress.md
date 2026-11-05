# Team progress (as of November 5, 2026)

Each of us commits our own work, so `git log --author="<name>"` shows who did what. The lists below describe each person's role, what they have done, and what they still need to add to the repo.

## Abdelrahman Naser: custom test suite and SpotBugs setup

Experiments: E3 (SpotBugs/FindSecBugs evaluation) and E4 (custom test suite).

Done so far:
- Set up SpotBugs with the FindSecBugs plugin on his own machine.
- Wrote the first sample vulnerable Java file (`InsecureCryptoSample.java`, with a hard-coded key and MD5) and used it to check that SpotBugs scans bytecode and loads the plugin correctly.
- The shared harness now runs FindSecBugs 1.12.0 on the full benchmark (`runs/20261104_baseline/fsb/`: 21 of 96 detected, no false alarms) and on everything in `custom_tests/src/`.

Still to commit:
- `InsecureCryptoSample.java` and the output of his first SpotBugs run (moved into `custom_tests/` and `logs/`).
- The remaining 12 custom test files listed in `docs/contribution_plan.md`, with a row for each in `custom_tests/ground_truth_custom.csv`.

## Mark Tymoshenko: CryptoGuard setup and refinement analysis

Experiments: E1 (CryptoGuard on the benchmark and custom files) and E2 (refinement ablation).

Done so far:
- Got both CryptoGuard versions building without Gradle or Maven Central (`harness/build.sh`). Found the paper-era CryptoGuard commit (`ccs-submission`, `4097f921`) and the 112-case benchmark commit (`734aecb`) in their git histories.
- Wrote the harness: `setup.sh`, `build.sh`, `run_tool.sh`, `run_all.sh`, `sanity.sh`, `ground_truth.py` and `score.py`.
- Ran the baseline (`runs/20261104_baseline/`). CG-2019 detected 77 of 96 and CG-2020 detected 82 of 96, both with no false alarms. CG-2019 matches the paper's Table 7 exactly on 13 of the 16 rules.
- Ran sanity checks S1 to S6 and recorded the single-case failure trace.
- First pass at the ablation: refinement removed 67 of 160 alerts (42 percent) on the benchmark.
- Found two tool bugs. CG-2020 reports the location of its TrustManager and HostnameVerifier alerts as `UNKNOWN`, and CG-2019 flags `KeyGenerator.init(256)` as a hard-coded key.
- Wrote the three pilot test files.

Next:
- Build a version of CryptoGuard with the refinement checks turned off, for the full ablation.
- Dump the backward slice for the missed hard-coded key case to find where the constant is dropped.

## Daniel Mulraney: threat model and discrepancy framework

Experiment: E5 (threat model mapping and discrepancy analysis).

Done so far:
- Drafted the schema for the evaluation table.
- Mapped the target JCA vulnerability categories to CWEs (CWE-327 broken or risky crypto algorithm, CWE-321 hard-coded cryptographic key) for tracking discrepancies.
- The inputs for his matrix are ready. Every run writes `scored/alerts.csv` (each alert with its tool rule, the matching paper rule, class and test case) and `scored/per_case.csv` for all three tools.

Still to commit:
- `docs/initial_discrepancy_schema.md` with the table schema and the CWE mapping.
- A first list of cases where CryptoGuard and SpotBugs disagree, built from the baseline run.
