# Results

Final results for the CryptoGuard evaluation. All numbers come from `runs/20261123_final/`, which anyone can regenerate with the commands at the end of this file.

## Summary

- The paper's precision claim holds on the benchmark. Neither CryptoGuard version raised a false alarm on any of the 16 secure benchmark cases.
- Recall is lower than the paper reports. The paper-era build finds 77 of 96 misuses and the current release finds 82, against the paper's 85.
- The paper-era build matches the paper's per-rule counts on 13 of 16 rules. All 6 of its hard-coded key misses come from one blind spot: it loses the key when the key passes through `Arrays.copyOf`, and every hard-coded key case in the benchmark does that.
- Turning refinement off finds 6 more benchmark cases, but 5 of those are flagged only because of an array length or index, not the secret. Only one is a real recovery: a hard-coded PBE password stored in a `char[]`, which refinement drops because it only keeps constants written into `byte[]` arrays. Turning refinement off also adds one real false alarm. So the paper's claim that refinement only removes false positives holds up well on the benchmark, with one exception.
- On Abdul's 15 test files, both CryptoGuard versions get 12 of 13 misuses with no false alarms. SpotBugs with FindSecBugs gets 10 of 13. The one CryptoGuard miss is a 512-bit RSA key. We traced it to a string-handling bug: CryptoGuard never checks the RSA key size inside a method that has an array parameter, and `main(String[] args)` is such a method. The same code in a method without an array parameter is caught.

## Tools

| Name used here | What it is |
|---|---|
| CG-2019 | CryptoGuard `ccs-submission` branch, commit `4097f921` (January 2019). Closest public code to the paper |
| CG-2019, refinement off | The same code with `harness/patch_norefine.py` applied and run with `-Dcg.norefine=true` |
| CG-2020 | CryptoGuard release v04.05.03, commit `92551eeb` |
| FindSecBugs | SpotBugs 4.6.0 with the FindSecBugs 1.12.0 plugin |

## 1. CryptoAPI-Bench (112 cases, 96 misuse, 16 secure)

| Tool | Detected | False alarms | Missed | Precision | Recall |
|---|---|---|---|---|---|
| Paper, CryptoGuard (Table 7) | 85 | 0 | 11 | 100% | 88.5% |
| CG-2019 | 77 | 0 | 19 | 100% | 80.2% |
| CG-2019, refinement off | 83 | 1 | 13 | 98.8% | 86.5% |
| CG-2020 | 82 | 0 | 14 | 100% | 85.4% |
| Paper, SpotBugs 3.0.1 (Table 7) | 26 | 11 | 70 | 70.3% | 27.1% |
| FindSecBugs 1.12.0 | 21 | 0 | 75 | 100% | 21.9% |

Per-rule counts for each tool, next to the paper's, are in `runs/20261123_final/<tool>/scored/summary.md`. For CG-2019 the only rules that differ from the paper are rule 1 (0 detected vs 5), rule 2 (4 vs 6) and rule 3 (4 vs 5).

These numbers are identical to the November 4 baseline run, including the CG-2020 issue hash used in sanity check S5.

## 2. Custom test suite (Abdul's 15 files plus our 3 pilot files)

Abdul's 15 files cover 13 misuse patterns and 2 secure versions. His own SpotBugs report (`custom_tests/spotbugs_custom_report.txt`) and the harness's FindSecBugs run agree on every file.

| File | Rule | Expected | CG-2019 | CG-2020 | FindSecBugs |
|---|---|---|---|---|---|
| HardcodedKeyTest1 | 1 hard-coded key | misuse | detected | detected | detected |
| WeakHashMD5Test2 | 16 broken hash | misuse | detected | detected | detected |
| WeakHashSHA1Test3 | 16 broken hash | misuse | detected | detected | detected |
| ECBModeTest4 | 11 ECB mode | misuse | detected | detected | detected |
| DefaultAESECBTest5 | 11 ECB mode (plain `"AES"` defaults to ECB) | misuse | detected | detected | detected |
| StaticIVTest6 | 12 static IV | misuse | detected | detected | detected |
| WeakCipherDESTest7 | 14 broken cipher | misuse | detected | detected | detected |
| InsecureRandomTest8 | 9 untrusted PRNG | misuse | detected | detected | detected |
| StaticSeedSecureRandomTest9 | 8 predictable seed | misuse | detected | detected | missed |
| SmallRSAKeyTest10 | 15 RSA key under 2048 bits | misuse | missed | missed | detected |
| HardcodedKeyStorePassTest11 | 3 hard-coded keystore password | misuse | detected | detected | detected |
| LowIterationPBETest12 | 13 PBE iterations under 1000 | misuse | detected | detected | missed |
| ObfuscatedKeySliceTest13 | 1 key built through `StringBuilder.reverse()` | misuse | detected | detected | missed |
| SafeAESGCMTest14 | secure AES-GCM | secure | no alert | no alert | no alert |
| SafeSHA256Test15 | secure SHA-256 | secure | no alert | no alert | no alert |

Totals for Abdul's 15 files:

| Tool | Detected (of 13) | False alarms (of 2) |
|---|---|---|
| CG-2019 | 12 | 0 |
| CG-2020 | 12 | 0 |
| FindSecBugs | 10 | 0 |

Notes:

- FindSecBugs misses the three cases that need data-flow tracking: the seed constant, the iteration count, and the key hidden behind `StringBuilder.reverse()`. CryptoGuard catches all three.
- `LowIterationPBETest12` also uses a hard-coded salt (`{1, 2, ..., 8}`). Both CryptoGuard versions flag the salt as well (rule 10). FindSecBugs does not. We only score each file on its main rule, so this extra finding isn't counted.
- The three pilot files behave as described in `docs/contribution_plan.md`. Both versions miss the hex-decoded key and raise a false alarm on the infeasible iteration count, as the paper's Section 7 predicts. CG-2019 also flags `KeyGenerator.init(256)` as a hard-coded key, and CG-2020 doesn't.
- Turning refinement off changes nothing on the custom files.

## 3. Refinement ablation

The paper says the five refinement insights (RI-I to RI-V) remove 76 to 80 percent of alerts on real projects, and that every removed alert was a false positive.

How we tested it: `harness/patch_norefine.py` changes the paper-era code so that, when run with `-Dcg.norefine=true`, every constant a refinement would discard is reported instead. The rules' own checks stay in place, such as the key-size limit and the 1000-iteration limit. With the switch off, the patched build gives byte-identical output to the original on both the benchmark and the custom files (sanity check S7).

What we found on the benchmark:

- With refinement on, 67 of 160 alert entries (42 percent) are in the group refinement removes. That is lower than the paper's 76 to 80 percent, but the benchmark is small, synthetic code, not the large projects the paper measured.
- With refinement off, 6 more misuse cases are detected and 1 secure case becomes a false alarm.

| Case | Change | Constant that triggered it | Real detection? |
|---|---|---|---|
| PredictablePBEPasswordBBCase2 | missed to detected | `115`, the character `'s'` in `char[] defaultKey = {'s'}` | Yes |
| PredictableSeedsBBCase2 | missed to detected | array length `1` and index `0` in `new byte[]{seed}` | No, the seed value `100` is never reported |
| PredictableSeedsABICase4 | missed to detected | array index `0` | No |
| PredictableSeedsABSCase2 | missed to detected | array index `0` | No |
| StaticInitializationVectorABICase2 | missed to detected | array length `1` and index `0` | No |
| StaticSaltsABICase2 | missed to detected | array length `1` and index `0` | No |
| StaticInitializationVectorCorrected | no alert to false alarm | array length `16` in `new byte[16]` | False alarm |

So 5 of the 6 extra detections are the bookkeeping constants that RI-III exists to remove. Counting them would be getting the right answer for the wrong reason. The secure-case false alarm is also an array length. This supports the paper's claim.

The one real loss is the PBE password. The paper-era checker only keeps integer constants written into `byte[]` arrays and drops the rest as "contextually incompatible" (RI-IV). But `PBEKeySpec` takes the password as a `char[]`, so a hard-coded password written as a character array is thrown away. This is a case where refinement causes a false negative.

## 4. Root causes of the misses

We wrote small probe files to isolate each miss. They are in `probes/`, and `harness/probes.sh` runs them. The results are in `runs/20261123_final/probes/PROBES.md`.

### Hard-coded keys and `Arrays.copyOf` (the November 4 failure trace)

`PredictableCryptographicKeyBBCase1` stores the key string in a local variable, calls `getBytes()`, pads it with `Arrays.copyOf(keyBytes, 16)`, and passes it to `SecretKeySpec`. Both CryptoGuard versions miss it.

| Probe | CG-2019 | CG-2019, refinement off | CG-2020 |
|---|---|---|---|
| Literal `"defaultkey".getBytes()` | detected | detected | detected |
| Literal `.getBytes()` through `Arrays.copyOf` | missed | missed | detected |
| String in a local variable, then `getBytes()` | detected | detected | missed |
| Local variable, padded with `System.arraycopy` | missed | only the array length `16` | missed |
| Local variable through `Arrays.copyOf` (the benchmark case) | missed | missed | missed |

The pattern is clear:

- CG-2019 loses the key whenever it goes through `Arrays.copyOf`. Turning refinement off doesn't help, so the constant never makes it into the program slice at all. Raising the clipping depth doesn't help either (we tried depths 1, 2, 3 and 5 on November 4).
- CG-2020 handles `Arrays.copyOf`, but loses the key when the string is stored in a local variable before `getBytes()` is called.
- The benchmark case has both patterns, so both versions miss it.

All 7 hard-coded key files in the benchmark (the 6 misuse cases and the corrected version) use `Arrays.copyOf`. This explains why CG-2019 detects none of them while the paper reports 5. `Arrays.copyOf` has been in these files since the benchmark's first commit (February 2019), so the paper's benchmark had it too. The paper's tool must have handled it in a way the public `ccs-submission` code doesn't, or the difference comes from running it against a different Java runtime library (see threats to validity).

Our November 4 guess, that `String.getBytes()` was the problem, was wrong. CG-2019 handles `getBytes()` fine.

### RSA key size in `main`

`SmallRSAKeyTest10` calls `KeyPairGenerator.getInstance("RSA")` and `initialize(512)` directly in `main`. Both versions miss it.

| Probe | CG-2019 | CG-2020 |
|---|---|---|
| `initialize(512)` in `main` | missed | missed |
| `int keysize = 1024; initialize(keysize)` in `main` | missed | missed |
| Same, plus an RSA `Cipher` using the key pair, in `main` | missed | missed |
| `initialize(512)` in a static method `go()` called from `main` | detected | detected |
| `int keysize = 1024; initialize(keysize)` in an instance method `go()` called from `main` | detected | detected |
| `initialize(512)` in a static method `go(byte[] unused)` called from `main` | missed | missed |

Whether the key size is a literal or a variable makes no difference, and turning refinement off makes no difference either. What matters is whether the method containing the code has an array parameter.

We found the cause by adding debug output to a scratch copy of CG-2019. The rule-15 checker works in two passes. The first pass records each place `KeyPairGenerator.initialize` is called, as a string like `<Class: void go()>[8]`, where `[8]` is the line number. To build that string, it takes the method name up to the first `[` character (`method.substring(0, method.indexOf('['))`). For `main(java.lang.String[])`, the first `[` is the one inside `String[]`. So the recorded call site becomes `<Class: void main(java.lang.String[8]`, which never matches the real method name in the second pass. The checker then skips the key size entirely. The same line is in both versions: `DefaultExportGradeKeyFinder.java` line 68 in CG-2019 and line 130 in CG-2020.

The benchmark's rule-15 case puts its code in `go()`, which has no parameters, so the benchmark never triggers this bug. Abdul's file is the only test that does.

## 5. The paper's claims

| Claim | Verdict | Evidence |
|---|---|---|
| C1. 85 detected, 0 false alarms, 11 missed on the 112 benchmark cases | Precision holds, recall doesn't fully. We get 77 (paper-era code) and 82 (current release), both with 0 false alarms | Section 1 |
| C2. 100% precision and recall on the 6 rules all tools share, and SpotBugs is much worse on advanced cases | Precision holds. Recall on the shared rules is 85.7% for CG-2019 (basic and advanced) and 85.7% basic / 92.9% advanced for CG-2020, mostly because of the hard-coded key misses. FindSecBugs gets 7.1% recall on the advanced shared-rule cases (3 of 42), close to the 7% the paper reports for SpotBugs. Unlike the paper's SpotBugs run, it raised no false alarms | Section 1, `summary.md` Table 3 section |
| C3. Refinement removes 76 to 80 percent of alerts, all of them false positives | Mostly holds on the benchmark. 42 percent of alert entries removed. One real misuse is lost (char-array PBE password) | Section 3 |
| C4. Misses come from clipping, false alarms from path insensitivity | The path-insensitivity false alarm is confirmed (pilot file). The misses we traced come from other causes: `Arrays.copyOf` breaking the slice, a local string variable in CG-2020, and the array-parameter bug in rule 15 | Sections 2 and 4 |

## Threats to validity

- The ground truth for the benchmark is rebuilt from file names. It matches the paper's totals, but differs by one case on rules 1 and 3.
- CG-2019 is the closest public code to the paper. It may not be the exact build the authors used.
- The CG-2019 code was written for Java 7, and the paper used Java 7 runtime libraries. Java 7 can't be installed on current Ubuntu, so we analyse against Java 8's runtime library. This could affect how JDK methods such as `Arrays.copyOf` are handled.
- CG-2020 runs on JDK 21. Its results are the same from run to run, but we never compared them with a JDK 8 run.
- FindSecBugs 1.12.0 on SpotBugs 4.6.0 is not the SpotBugs 3.0.1 the paper used.
- Scoring is per file. A file counts as detected if any alert for its rule lands in that file. Section 3 shows why this matters: some "detections" point at the wrong constant. We checked the cases that changed in the ablation by hand, but not every true positive in the baseline.
- The custom suite is 18 files. That is enough to find specific gaps, not to estimate precision or recall on real code.

## How to reproduce

```bash
bash harness/setup.sh
bash harness/build.sh
bash harness/run_all.sh myrun      # all tools on the benchmark and the custom tests, including refinement off
bash harness/sanity.sh myrun       # sanity checks S1 to S7
bash harness/probes.sh myrun       # root-cause probes
```
