# Team progress — evidence by member (as of 2026-11-04)

Evidence = commits in this repo (`git log --author=<name>`) plus the files listed. Each member commits their own work so authorship is checkable.

## Mark Tymoshenko — CryptoGuard setup & false-positive refinement analysis

Owned experiments: E1 (CryptoGuard on 112 cases + custom files), E2 (refinement ablation).

Done:
- Built both CryptoGuard versions without Maven Central/Gradle (`harness/build.sh`); found and pinned the paper-era tool commit (`ccs-submission`, `4097f921`) and the paper's 112-case benchmark commit (`734aecb`).
- Wrote the harness: `setup.sh`, `build.sh`, `run_tool.sh`, `run_all.sh`, `sanity.sh`, `ground_truth.py`, `score.py`.
- E1 baseline: `runs/20261104_baseline/cg2019/` and `cg2020/` — CG-2019 77/96 TP, CG-2020 82/96 TP, both 0 FP. CG-2019 matches paper Table 7 exactly on 13/16 rules; the whole gap is in rules 1–3 (constant keys/passwords).
- Sanity checks S1–S6 and the single-case failure trace (`runs/20261104_baseline/sanity/`).
- E2 first cut: refined-away alerts recovered from CG-2019's "Rule Na" output — 67 of 160 alerts (41.9%) removed; recovering them would catch up to 6 more misuse cases and add 1 false alarm.
- Found two tool issues: CG-2020 reports TrustManager/HostnameVerifier alerts with location `UNKNOWN`; CG-2019 flags `KeyGenerator.init(256)` as a hard-coded key (pilot P3).

Next: patched CG build with RI checks disabled for a full ablation (needed because RI-III removals are not printed); manual check of which constant each "would be detected without refinement" case relies on.

## Abdelrahman Naser — custom test suite & SpotBugs/FindSecBugs evaluation

Owned experiments: E3 (FindSecBugs on bench + custom), E4 (custom suite).

- Harness support is ready: FindSecBugs 1.12.0 runs on the benchmark (`runs/20261104_baseline/fsb/`, 21/96 TP, 0 FP) and on anything in `custom_tests/src/`.
- **TODO (Abdelrahman):** commit the custom test files to `custom_tests/src/custom/<name>/` with rows in `custom_tests/ground_truth_custom.csv`, and add a line here linking them. The 12 planned targets are in `docs/contribution_plan.md`.

## Daniel Mulraney — threat model & comparative analysis

Owned experiments: E5 (threat-model mapping; FP/FN discrepancy analysis).

- Inputs are ready: every run writes `scored/alerts.csv` (each alert with tool rule, mapped paper rule, class, case) and `scored/per_case.csv` for all three tools, so cross-tool disagreements can be listed directly.
- **TODO (Daniel):** commit the threat-model mapping table and the first discrepancy list (e.g. `docs/discrepancy_analysis.md`) and add a line here linking them.
