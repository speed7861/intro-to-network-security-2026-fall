# Checkpoint submission — 2026-11-04

Team: Abdelrahman Naser, Mark Tymoshenko, Daniel Mulraney · ECE 424 Fall 2026 · CryptoGuard (CCS'19)

| # | Requirement | Where |
|---|---|---|
| 1 | Runnable baseline / harness + instructions | [`README.md` → Quick start](README.md), scripts in [`harness/`](harness/) |
| 2 | One checkable trace / failure log, sanity check named and explained | [`runs/20261104_baseline/sanity/trace_PredictableCryptographicKeyBBCase1.log`](runs/20261104_baseline/sanity/trace_PredictableCryptographicKeyBBCase1.log) + [`SANITY.md`](runs/20261104_baseline/sanity/SANITY.md) — explained below |
| 3 | Bounded-contribution plan | [`docs/contribution_plan.md`](docs/contribution_plan.md) |
| 4 | Evidence of each member's work | [`docs/team_progress.md`](docs/team_progress.md) + `git log` |
| 5 | Updated protocol and logs | [`docs/protocol.md`](docs/protocol.md), [`logs/LOG.md`](logs/LOG.md), raw outputs in [`runs/20261104_baseline/`](runs/20261104_baseline/) |
| 6 | Fallback trace | `runs/20261104_baseline/` at commit **`6874178`** — details below |

## 1. Baseline status

The harness builds and runs CryptoGuard (paper-era build CG-2019 and current release CG-2020) and FindSecBugs on the paper's 112-case CryptoAPI-Bench, and scores each case against ground truth.

| | TP | FP | FN | Precision | Recall |
|---|---|---|---|---|---|
| Paper — CryptoGuard (Table 7) | 85 | 0 | 11 | 100% | 88.5% |
| Ours — CG-2019 | 77 | 0 | 19 | 100% | 80.2% |
| Ours — CG-2020 | 82 | 0 | 14 | 100% | 85.4% |
| Paper — SpotBugs 3.0.1 | 26 | 11 | 70 | 70.3% | 27.1% |
| Ours — FindSecBugs 1.12.0 | 21 | 0 | 75 | 100% | 21.9% |

The precision claim reproduces (0 false positives on the benchmark for all tools). Recall is 3–8 cases short of the paper. CG-2019 matches the paper's per-rule true-positive counts exactly on 13 of 16 rules; the entire gap sits in rules 1–3 (hard-coded keys and passwords).

## 2. Failure trace and sanity checks

**Sanity check S4 — single-case failure probe.** We take `PredictableCryptographicKeyBBCase1`, the simplest hard-coded-key case in the benchmark (one method, `"defaultkey".getBytes()` → `SecretKeySpec`), compile it alone into a one-class jar, and run both CryptoGuard builds on it.

- *Expected (paper Table 7):* rule 1 is 5/5 detected, so this case should raise a "constant key" alert.
- *Observed:* CG-2019 prints no rule-3 ("constant keys") block and CG-2020 returns `"Issues": []`. The trace file shows the source with line numbers, both tools' full output, and the SHA-256 of the exact jar, so anyone can rerun it with `bash harness/sanity.sh <run>`.
- *What we ruled out:* environment (the same miss on JDK 8 with the paper-era build and on JDK 21 with the current build); clipping depth (`-depth 1/2/3/5` all miss); harness attribution (the tool emits nothing at all for this jar). *Working hypothesis:* the constant reaches the key through `String.getBytes()`, an orthogonal call, and a refinement (RI-I/RI-II) drops it. Next step: dump the backward slice.

**Why we trust the rest of the run** — the other checks in `SANITY.md`:

| Check | Result |
|---|---|
| S1 Ground truth vs paper | 112 cases / 96 misuse / 16 secure — matches; per-rule counts match on 14/16 rules (rules 1 and 3 off by one case each) |
| S2 Negative controls | all 3 tools raise no target-rule alert on the 16 secure cases |
| S3 Positive control | `BrokenHashBBCase2` alone → exactly one MD5 alert |
| S5 Determinism | two CG-2020 runs → identical 87-issue set (hash `5f798a8e0a325499`) |
| S6 Paper-era agreement | CG-2019 per-rule TP equals paper on 13/16 rules |

S2/S3 also caught a real harness bug during development: the first scored run reported 0 TP for every tool because the class-to-source map was empty (see `logs/LOG.md`, 21:21).

## 3. Bounded contribution (summary)

15 labelled Java files aimed at the failure modes the paper predicts in §7 and the misses our baseline exposed, each with a written prediction, run through all three tools. A 3-file pilot already ran end to end: the paper's own predictions held (hex-decoded constant key → missed; infeasible-path `iteration = 0` → false alarm), and it surfaced a false positive in CG-2019 (`KeyGenerator.init(256)` flagged as a hard-coded key). Full plan: `docs/contribution_plan.md`.

## 6. Fallback trace

If a later snapshot is missing or invalid, use **`runs/20261104_baseline/`** at commit **`6874178`** (`git checkout 6874178`; browse at https://github.com/speed7861/intro-to-network-security-2026-fall/tree/6874178/runs/20261104_baseline):

- primary: `runs/20261104_baseline/cg2020/` — `cg2020_raw.json` (raw tool output), `cg2020_manifest.txt` (command, versions, exit code, input/output SHA-256), `scored/` (per-case CSV + summary);
- failure trace: `runs/20261104_baseline/sanity/trace_PredictableCryptographicKeyBBCase1.log`;
- integrity: `runs/20261104_baseline/SHA256SUMS` and `sanity/SHA256SUMS`.

It is regenerable from the pins: `bash harness/setup.sh && bash harness/build.sh && bash harness/run_all.sh X && bash harness/sanity.sh X`, which should reproduce the same issue-set hash (S5).
