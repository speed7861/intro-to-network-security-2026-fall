# Intro to Network Security — Fall 2026 (Rutgers ECE 424)

**Project:** High-precision evaluation of cryptographic API misuses using CryptoGuard
**Team:** Abdelrahman Naser · Mark Tymoshenko · Daniel Mulraney
**Paper:** Rahaman et al., *CryptoGuard: High Precision Detection of Cryptographic Vulnerabilities in Massive-sized Java Projects*, ACM CCS 2019 (arXiv:1806.06881)

> **Graders: start at [`CHECKPOINT.md`](CHECKPOINT.md)** — it maps each checkpoint requirement to a file in this repo.

## What this repo does

A reproducible harness that runs three static analysers on the paper's **112-case CryptoAPI-Bench** and on our own test files, then scores them against case-level ground truth:

| Tool | Version | Role |
|---|---|---|
| CryptoGuard **CG-2019** | `ccs-submission` branch, commit `4097f921` (Jan 2019) | closest public code to the paper |
| CryptoGuard **CG-2020** | latest release v04.05.03, commit `92551eeb` | current tool |
| SpotBugs + FindSecBugs | FindSecBugs CLI 1.12.0 (SpotBugs 4.6.0) | linter baseline |

Baseline result (run `runs/20261104_baseline`, all 112 cases, case-level scoring):

| | TP | FP | FN | Precision | Recall |
|---|---|---|---|---|---|
| Paper, CryptoGuard (Table 7) | 85 | 0 | 11 | 100% | 88.5% |
| **Ours, CG-2019** | 77 | 0 | 19 | 100% | 80.2% |
| **Ours, CG-2020** | 82 | 0 | 14 | 100% | 85.4% |
| Paper, SpotBugs 3.0.1 (Table 7) | 26 | 11 | 70 | 70.3% | 27.1% |
| **Ours, FindSecBugs 1.12.0** | 21 | 0 | 75 | 100% | 21.9% |

## Quick start (Ubuntu 22.04/24.04, ~10 min, no Maven Central or Gradle needed)

```bash
git clone https://github.com/<owner>/intro-to-network-security-2026-fall.git
cd intro-to-network-security-2026-fall
bash harness/setup.sh            # apt: JDK 8 + JDK 21 + Java libs; clones pinned tool/bench commits into ext/
bash harness/build.sh            # builds bench112.jar, custom.jar, CG-2019, CG-2020 into build/
bash harness/run_all.sh myrun    # runs 3 tools x (bench112 + custom tests), scores -> runs/myrun/
bash harness/sanity.sh myrun     # sanity checks + single-case failure trace -> runs/myrun/sanity/
```

Then read `runs/myrun/<tool>/scored/summary.md` and `runs/myrun/sanity/SANITY.md`.
Each tool run also writes a `*_manifest.txt` (exact command, versions, exit code, wall time, SHA-256 of input jar and raw output). Re-running on the same pins gives byte-identical issue sets (sanity check S5).

Run a single tool on any jar: `bash harness/run_tool.sh cg2020 path/to/app.jar runs/adhoc/`

## Layout

```
harness/      setup.sh, build.sh, run_tool.sh, run_all.sh, sanity.sh, ground_truth.py, score.py, pins.env
data/         ground_truth_bench112.csv  (112 cases: rule, category, label)
custom_tests/ src/custom/...  + ground_truth_custom.csv   (our bounded contribution goes here)
runs/         one folder per run: raw tool output, manifests, scored CSV/MD, SHA256SUMS
docs/         protocol.md, contribution_plan.md, team_progress.md
logs/LOG.md   dated lab notebook
```

## Safety / scope

Static analysis only, on public open-source benchmark code and our own toy files. No live systems, no network attacks. Tool binaries are fetched from upstream GitHub and verified by SHA-256.

## License note

CryptoGuard is GPL-3.0 and is fetched at setup time, not vendored. CryptoAPI-Bench is fetched the same way.
