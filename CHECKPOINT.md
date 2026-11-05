# Midpoint Project Evidence Package

Course: ECE 424 / ECE 539, Fall 2026
Project: High-Precision Evaluation of Cryptographic API Misuses using CryptoGuard
Team: Abdelrahman Naser, Mark Tymoshenko, Daniel Mulraney
Submitted: November 5, 2026
Repository: https://github.com/speed7861/intro-to-network-security-2026-fall

This file covers each item asked for at the checkpoint and points to where the evidence is in the repo.

| Item | Where to find it |
|---|---|
| 1. Runnable baseline and instructions | Section 1 below, `README.md`, scripts in `harness/` |
| 2. Checkable trace and sanity check | Section 2 below, `runs/20261104_baseline/sanity/` |
| 3. Bounded-contribution plan | Section 3 below, `docs/contribution_plan.md` |
| 4. Team progress | Section 4 below, `docs/team_progress.md`, `git log` |
| 5. Updated protocol and logs | Section 5 below, `docs/protocol.md`, `logs/LOG.md` |
| 6. Fallback trace | Section 6 below |

## 1. Runnable baseline

We have a working harness that builds and runs three static analysis tools on the 112-case version of CryptoAPI-Bench (the version used in the paper) and on our own test files, then scores the output against ground truth.

The three tools are:

- CryptoGuard "CG-2019": the `ccs-submission` branch from January 2019 (commit `4097f921`). This is the closest public code to what the paper evaluated.
- CryptoGuard "CG-2020": the latest release, v04.05.03 (commit `92551eeb`).
- SpotBugs 4.6.0 with the FindSecBugs 1.12.0 plugin.

To run everything on Ubuntu 22.04 or 24.04 (takes about 10 minutes):

```bash
git clone https://github.com/speed7861/intro-to-network-security-2026-fall.git
cd intro-to-network-security-2026-fall
bash harness/setup.sh          # installs JDK 8 and 21 and the Java libraries, fetches the pinned tool and benchmark versions
bash harness/build.sh          # compiles the benchmark, our custom tests, and both CryptoGuard versions
bash harness/run_all.sh myrun  # runs all three tools and scores them
bash harness/sanity.sh myrun   # runs the sanity checks
```

Results end up in `runs/myrun/<tool>/scored/summary.md`. The README also shows how to run SpotBugs by hand on the custom test folder.

Baseline numbers from `runs/20261104_baseline` (96 vulnerable cases, 16 secure cases):

| Tool | Correct detections | False alarms | Missed | Precision | Recall |
|---|---|---|---|---|---|
| CryptoGuard, as reported in the paper (Table 7) | 85 | 0 | 11 | 100% | 88.5% |
| CG-2019 (our run) | 77 | 0 | 19 | 100% | 80.2% |
| CG-2020 (our run) | 82 | 0 | 14 | 100% | 85.4% |
| SpotBugs 3.0.1, as reported in the paper | 26 | 11 | 70 | 70.3% | 27.1% |
| SpotBugs + FindSecBugs 1.12.0 (our run) | 21 | 0 | 75 | 100% | 21.9% |

So far the paper's precision claim holds up: none of the tools flagged any of the 16 secure cases. Recall is lower than the paper reports. CG-2019 matches the paper's per-rule counts exactly on 13 of the 16 rules, and the whole difference is in rules 1 to 3 (hard-coded keys and passwords).

## 2. Checkable trace and sanity check

Sanity check name: S4, single-case failure probe.

Trace file: `runs/20261104_baseline/sanity/trace_PredictableCryptographicKeyBBCase1.log`

We took `PredictableCryptographicKeyBBCase1`, which is the simplest hard-coded key case in the benchmark. It is one method that does `"defaultkey".getBytes()` and passes the result to `SecretKeySpec`. We compiled it into a jar by itself and ran both CryptoGuard versions on it. The trace file has the source code with line numbers, the full output of both tools, and the SHA-256 hash of the jar so anyone can rerun it.

According to Table 7 in the paper, all 5 rule-1 cases are detected, so we expected an alert. Neither version reported one. CG-2019 printed no constant-key result and CG-2020 returned an empty issue list.

We checked a few things before trusting this result. It is not the Java version, since the 2019 build on JDK 8 and the 2020 build on JDK 21 both miss it. It is not the clipping depth setting, since depths 1, 2, 3 and 5 all miss it. It is not our scoring script either, because the tool produces no output at all for this jar. Our current guess is that the constant passes through `String.getBytes()`, which CryptoGuard treats as an orthogonal call, and one of the refinement rules (RI-I or RI-II) throws it away. We plan to dump the backward slice to check this.

We also ran these checks to make sure the rest of the run can be trusted. The full results are in `runs/20261104_baseline/sanity/SANITY.md`.

| Check | What we did | Result |
|---|---|---|
| S0 | SpotBugs/FindSecBugs harness validation: run on the benchmark and on our custom tests | Exit code 0, 70 security alerts on the benchmark, XML report written (`fsb/fsb_manifest.txt`) |
| S1 | Compare our ground truth with the paper | Same totals (112 cases, 96 vulnerable, 16 secure). Per-rule counts match on 14 of 16 rules |
| S2 | Negative controls: the 16 secure cases | No tool flagged any of them |
| S3 | Positive control: `BrokenHashBBCase2` (uses MD5) on its own | Exactly one MD5 alert |
| S4 | Failure probe (above) | Miss reproduced |
| S5 | Run CG-2020 twice | Same 87 issues both times (hash `5f798a8e0a325499`) |
| S6 | CG-2019 per-rule detections vs paper Table 7 | Equal on 13 of 16 rules |

The checks also caught a bug in our own harness. The first scored run showed 0 detections for every tool because the file that maps compiled classes back to test cases was empty. The details are in `logs/LOG.md`.

## 3. Bounded-contribution plan

Beyond reproducing the baseline, we are adding three things. The full plan is in `docs/contribution_plan.md`.

1. A custom test suite. We are expanding our first sample files into 15 targeted Java test cases. They cover JCA misuse patterns such as static IV reuse, insecure cipher modes and weak key derivation, plus the cases the paper itself says CryptoGuard should get wrong (Section 7). Each file has its expected result written down before we run it. Three pilot files are already in the repo and have been run through all three tools.
2. An ablation of the refinement step. We compare CryptoGuard with its false-positive refinements turned on and turned off, to test the paper's claim that refinement removes 76 to 80 percent of alerts and that all of them are false positives.
3. A discrepancy matrix. For every test case we record where CryptoGuard and SpotBugs disagree and whether each disagreement is a false positive or a false negative, then group them by vulnerability type (CWE).

The pilot already gave useful results. A hard-coded key decoded from hex was missed, and an iteration count of 0 on a path that never reaches the key was flagged anyway. Both match what the paper predicts. It also found a false alarm in CG-2019, which flags `KeyGenerator.init(256)` as a hard-coded key. CG-2020 does not have this problem.

## 4. Team progress so far

Abdelrahman Naser (custom test suite and SpotBugs setup): set up SpotBugs with the FindSecBugs plugin locally and wrote the first sample vulnerable Java file to confirm that bytecode scanning works. In the shared harness, FindSecBugs now runs on the full benchmark and on the custom tests. Next he will write the remaining custom test files.

Mark Tymoshenko (CryptoGuard setup and refinement analysis): got both CryptoGuard versions building without Gradle or Maven, found the exact benchmark and tool commits that match the paper, wrote the harness and scoring scripts, ran the baseline and the sanity checks, and did a first pass at the refinement ablation.

Daniel Mulraney (threat model and discrepancy framework): drafted the schema for the evaluation table and mapped the target vulnerability categories to CWEs (CWE-327 broken or risky crypto, CWE-321 hard-coded key) for tracking discrepancies. The harness now writes every alert and every per-case result to CSV files, which feed directly into his matrix.

More detail, including what each person still needs to commit, is in `docs/team_progress.md`.

## 5. Updated experimental protocol

The full protocol is in `docs/protocol.md`. In short:

- Compilation: all test cases are compiled with javac to Java 8 bytecode, which is what both CryptoGuard versions expect.
- Static evaluation with SpotBugs: we run SpotBugs with FindSecBugs and record the detections.
- Main evaluation with CryptoGuard: we run both CryptoGuard versions on the 112 benchmark cases and on our custom test files.
- Metrics: precision = TP / (TP + FP) and recall = TP / (TP + FN), computed per test case and per rule.

What changed since the proposal:

- We pinned the benchmark to commit `734aecb`. The current version has 171 cases, and the 112-case version the paper used is only in the git history.
- We added the 2019 CryptoGuard build next to the current one, so we can tell whether a difference comes from the paper or from later changes to the tool.
- We use FindSecBugs 1.12.0 instead of SpotBugs 3.0.1 through SWAMP, because SWAMP is no longer available. Our SpotBugs numbers are therefore not expected to match the paper exactly.

Every step of the work is recorded with times in `logs/LOG.md`.

## 6. Fallback trace

If a later snapshot is missing or invalid, please use the folder `runs/20261104_baseline/` as of commit `6874178`:

https://github.com/speed7861/intro-to-network-security-2026-fall/tree/6874178/runs/20261104_baseline

- `cg2020/cg2020_raw.json` is the raw tool output. `cg2020/cg2020_manifest.txt` records the exact command, tool versions, exit code and file hashes. `cg2020/scored/` has the per-case results.
- `sanity/trace_PredictableCryptographicKeyBBCase1.log` is the failure trace from Section 2.
- `SHA256SUMS` in that folder can be used to check that no file has changed.

The same results can be regenerated from scratch with the four commands in Section 1, and check S5 confirms the output is the same each time.
