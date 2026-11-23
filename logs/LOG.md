# Lab notebook

Times are Eastern and approximate. The raw output for every entry is in `runs/`.

## Before November 4

Abdelrahman set up SpotBugs with the FindSecBugs plugin on his own machine and ran it on a first sample file with a hard-coded key and an MD5 hash, to check that bytecode scanning and the plugin worked. Daniel drafted the evaluation table schema and the CWE mapping (CWE-327, CWE-321). Mark started on the CryptoGuard build. These files still need to be committed to the repo (see `docs/team_progress.md`).

## November 4

21:12. Setup. Cloned CryptoGuard (latest commit `92551eeb`, v04.05.03) and CryptoAPI-Bench (latest commit `759622f`). The CryptoGuard Gradle build depends on jcenter, which has been shut down, and our build machine can't reach Maven Central. So we compile CryptoGuard directly with javac against the Java libraries from Ubuntu's packages (`harness/build.sh`).

21:15. First CG-2020 run. It takes about 8 seconds for the 112 cases. It missed `PredictableCryptographicKeyBBCase1`, a basic hard-coded key in a single method. We tried `-depth` values of 1, 2, 3 and 5 and it still missed it, so the clipping depth is not the cause.

21:17. The benchmark doesn't match the paper. The latest version has 195 Java files and 171 labeled cases, not 112. Looking through the git history, commits `5e3d0b4` and `734aecb` (March 2019) have exactly 112 test files, and commit `93875ff` (August 2019) added the rest. We pinned `734aecb` and built labels from the file names. The totals match the paper: 96 vulnerable and 16 secure.

21:18. Paper-era CryptoGuard. Found the `ccs-submission` branch, merged on January 4, 2019 (`4097f921`), and built it with JDK 8 and the Soot jar that comes with it. It misses the same case, so the miss isn't something that changed in later versions. This version prints the alerts removed by refinement in a separate group ("Rule 3a" and so on), which lets us do part of the ablation without changing any code.

21:19. FindSecBugs. The release file for version 1.13.0 is missing on GitHub (404), so we use 1.12.0 and check its SHA-256. It has to run on JDK 8. Our first try on JDK 21 failed with an exception and didn't write a report.

21:21. Harness bug. The first scored run showed 0 detections for every tool. The file that maps classes back to test cases was empty, because `javap -v` prints `SourceFile:` without the indentation our script expected. Fixed the pattern and reran.

21:22. Baseline run, `runs/20261104_baseline`.
- CG-2019: 77 detected, 0 false alarms, 19 missed (precision 100%, recall 80.2%). Same per-rule counts as the paper's Table 7 on 13 of 16 rules. The differences are rule 1 (0 vs 5), rule 2 (4 vs 6) and rule 3 (4 vs 5).
- CG-2020: 82 detected, 0 false alarms, 14 missed (precision 100%, recall 85.4%). All 20 field-sensitive cases detected. Two of its "misses" (rules 4 and 5) are actually found, but the tool reports the location as `UNKNOWN`.
- FindSecBugs 1.12.0: 21 detected, 0 false alarms, 75 missed (precision 100%, recall 21.9%). Only 5 of 42 inter-procedural cases and 1 of 20 field-sensitive cases.
- The paper reports 85 detected, 0 false alarms, 11 missed.
- Ground truth check: we count 6 vulnerable cases for rule 1 where the paper has 5, and 4 for rule 3 where the paper has 5. Probably the paper counted `PredictableCryptographicKeyABHCase1` (key stored in a String) under a different rule. Still open, and it doesn't change the totals.

21:23. Sanity checks (`runs/20261104_baseline/sanity/SANITY.md`). Negative controls pass for all three tools (none of the 16 secure cases flagged). The positive control passes. Two CG-2020 runs give the same issue hash, `5f798a8e0a325499`. The failure probe reproduces the miss. The first version of the sanity script gave CG-2019 the sanity folder as its dependency folder, so CG-2019 also scanned the other test jar in there. Fixed by giving it an empty folder.

21:24. Pilot custom tests (3 files). Both CryptoGuard versions behave the way the paper's Section 7 predicts: the key decoded from hex is missed, and the iteration count of 0 on a path that never reaches the key is flagged. Something new: CG-2019 flags `KeyGenerator.init(256)` as a hard-coded key. CG-2020 doesn't.

21:33. Tested a fresh clone of the repo from scratch. `setup.sh` failed when run without sudo, because of how the apt command was written. Fixed.

21:55. The fresh-clone build hung: `unzip` was waiting for a yes/no answer about overwriting a file. Fixed by making it non-interactive in `build.sh` and `setup.sh`.

22:00. The fresh clone now builds and reproduces every number above exactly, including the S5 issue hash. Published the repo on GitHub as https://github.com/speed7861/intro-to-network-security-2026-fall.

## November 5

10:50. Rewrote the documentation and merged in the team's midpoint write-up. `CHECKPOINT.md` now follows the structure of that write-up.

## November 23

10:55. Abdul committed his 15 test files and his SpotBugs report (`custom_tests/`). Daniel has left the course, so experiment E5 (discrepancy matrix) is dropped.

10:58. Changed `build.sh` to compile every `.java` file under `custom_tests/`, since Abdul's files are in the top folder with no package. Added labels for his files to `custom_tests/ground_truth_custom.csv`. Added an `extra_rules` column so an alert for any related rule on a secure file counts as a false alarm (for example ECB, static IV or DES on `SafeAESGCMTest14`). Made `score.py` attribute CG-2019 alerts to classes with no package.

11:00. First run on the 18 custom files. CG-2019: 12 detected, 2 false alarms (both pilot files), 2 missed. CG-2020: 12, 1, 2. FindSecBugs: 10, 0, 4. FindSecBugs agrees with Abdul's own report on every file. Both CryptoGuard versions miss `SmallRSAKeyTest10` (`initialize(512)` in `main`).

11:02. Wrote `harness/patch_norefine.py`. It patches a copy of CG-2019 so that `-Dcg.norefine=true` reports every constant a refinement would discard. The rules' own checks (key size, iteration count, pattern match) are left alone. In the paper-era code every refinement drop goes through the "others" list, so this covers all five insights. With the switch off, the patched build's output is identical to the original on the benchmark and the custom files (now sanity check S7).

11:03. Ablation on the benchmark: 83 detected, 1 false alarm, 13 missed with refinement off, vs 77, 0, 19 with it on. That is the same as the November 4 count of the "removed" group, so our note that RI-III drops alerts before they reach that group was wrong for this code. No change on the custom files.

11:04. The RSA miss isn't caused by refinement. Tried variants in `main`: literal vs variable key size, with and without an RSA `Cipher`. All missed. The same code moved into `go()`: detected. Added debug output to a scratch copy of CG-2019. The rule-15 checker records call sites by cutting the method name at the first `[`, and for `main(java.lang.String[])` that is the `[` in `String[]`, so the call site never matches. A helper method with a `byte[]` parameter is missed as well. Same line in both versions (`DefaultExportGradeKeyFinder.java` line 68 in CG-2019, line 130 in CG-2020).

11:06. The hard-coded key miss (November 4 failure trace). Abdul's `HardcodedKeyTest1` is nearly the same code and is detected. Variants show CG-2019 loses the key whenever it goes through `Arrays.copyOf`, even with refinement off, and CG-2020 loses it when the string sits in a local variable before `getBytes()`. The benchmark case has both. All 7 rule-1 benchmark files use `Arrays.copyOf`, which explains CG-2019's 0 of 6 on that rule. `copyOf` has been in those files since the benchmark's first commit (February 2019). Our November 4 guess about `String.getBytes()` was wrong.

11:08. Checked which constants the 6 extra ablation detections point at. Five are array lengths or indices (`new byte[]{seed}` gives length 1 and index 0), not the secret. The real one is `PredictablePBEPasswordBBCase2`, a password in a `char[]`, which the paper-era checker drops because it only keeps constants written into `byte[]` arrays. The new false alarm is the array length 16 in `StaticInitializationVectorCorrected`.

11:10. Saved the variants as `probes/` with `harness/probes.sh`. Added the refinement-off build to `run_all.sh` and S7 to `sanity.sh`.

11:12. Final run `runs/20261123_final`. All tools exit 0. Benchmark numbers for CG-2019, CG-2020 and FindSecBugs are identical to November 4, including the S5 hash `5f798a8e0a325499`. S7 passes.

11:20. Wrote `docs/results.md` and updated the protocol, contribution plan, team progress and README.

## Open questions

1. We never compared CG-2020 on JDK 8 with JDK 21. The Jackson library from Ubuntu's packages needs Java 17, and Maven Central isn't reachable from our build machine.
2. We couldn't test CG-2019 against a Java 7 runtime library, which is what it was written for. Java 7 can't be installed on current Ubuntu.
