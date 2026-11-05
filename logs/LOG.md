# Lab notebook

All times America/New_York (approximate, from the build machine's clock). Raw outputs for every entry are under `runs/`.

## 2026-11-04

**21:12 — Setup.** Cloned CryptoGuard (head `92551eeb`, v04.05.03) and CryptoAPI-Bench (head `759622f`). Gradle 6 wrapper and Maven Central are unreachable from our build machine, and the Gradle build uses jcenter (shut down), so we compile CryptoGuard directly with `javac` against Ubuntu-packaged libraries instead (`harness/build.sh`).

**21:15 — First CG-2020 run.** Runs in ~8 s on 112 cases. Missed `PredictableCryptographicKeyBBCase1` (a basic, single-method hard-coded key). Tried `-depth 1,2,3,5`: still missed, so orthogonal clipping depth is not the cause.

**21:17 — Benchmark version mismatch.** Bench head has 195 Java files / 171 labelled cases, not the paper's 112. `git ls-tree` shows commits `5e3d0b4` and `734aecb` (2019-03) have exactly 112 test files; `93875ff` (2019-08) adds the rest. → Pinned `734aecb`. Derived labels from file names; totals match the paper (96 misuse / 16 secure).

**21:18 — Paper-era tool.** Found branch `ccs-submission` merged 2019-01-04 (`4097f921`). Built it with JDK 8 + its bundled Soot. Also misses the same case → not a regression in the newer tool. CG-2019 prints refined-away constants as "Rule Na" groups, which gives a no-patch partial ablation.

**21:19 — FindSecBugs.** Release asset for 1.13.0 is missing on GitHub (404); 1.12.0 CLI works (SHA-256 pinned). Run it on JDK 8: our first attempt on JDK 21 aborted with an exception and wrote no report.

**21:21 — Harness bug caught by results.** First scored run gave 0 TP for every tool: the class→source map was empty because `javap -v` prints `SourceFile:` without indentation. Fixed the awk pattern; rerun.

**21:22 — Baseline `runs/20261104_baseline`.**
- CG-2019: 77 TP / 0 FP / 19 FN (P 100%, R 80.2%). Matches paper Table 7 per-rule TP on 13/16 rules; differences only in rules 1 (0 vs 5), 2 (4 vs 6), 3 (4 vs 5).
- CG-2020: 82 / 0 / 14 (P 100%, R 85.4%). Field-sensitive 20/20. Two of its misses (rules 4, 5) are actually detected but reported at location `UNKNOWN`.
- FindSecBugs 1.12.0: 21 / 0 / 75 (P 100%, R 21.9%); inter-procedural 5/42, field-sensitive 1/20.
- Paper: 85 / 0 / 11.
- Ground-truth per-rule check: our rule 1 has 6 positives vs paper 5, rule 3 has 4 vs 5. Likely `PredictableCryptographicKeyABHCase1` (key stored in a String) was counted under a different rule in the paper. Open question; does not change totals.

**21:23 — Sanity checks** (`runs/20261104_baseline/sanity/SANITY.md`): S2 negative controls pass for all tools (16/16 secure cases clean); S3 positive control passes; S5 two CG-2020 runs give identical issue hash `5f798a8e0a325499`; S4 failure probe reproduces the miss. First version of the sanity script passed the sanity folder as CG-2019's dependency dir, which made CG-2019 analyse the other probe jar too — fixed by using an empty deps dir.

**21:24 — Pilot custom probes** (3 files). Paper §7 predictions hold on both CryptoGuard builds: hex-decoded constant key → missed; infeasible-path `iteration = 0` → false alarm. New: CG-2019 flags `KeyGenerator.init(256)` as a constant key (fixed in CG-2020).

### Open questions / next steps
1. Why do both builds miss `PredictableCryptographicKeyBBCase1`? Next: dump the backward slice for `SecretKeySpec.<init>` param 0 and see where `"defaultkey"` is dropped (suspect `String.getBytes()` as a clipped orthogonal call with RI-I/RI-II).
2. Full ablation needs a patched build (RI-III removals are not printed).
3. Check whether CG-2020 on JDK 8 gives the same 87 issues as on JDK 21.
