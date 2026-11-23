# Bounded contribution plan

## How it turned out (November 23)

This is the plan from the midpoint checkpoint. The results are in `docs/results.md`. Here is how the final work differs from the plan below:

1. Custom test suite. Abdul's final 15 files aim for broad coverage of JCA misuse types (13 misuse, 2 secure) instead of the 12 targeted files listed below. Several of the targeted ideas were tested anyway as root-cause probes (`probes/`), including the `Arrays.copyOf` case (planned file #3). The suite found one CryptoGuard bug we hadn't predicted: RSA key size is never checked inside a method with an array parameter, such as `main`.
2. Refinement ablation. Done with a patched build (`harness/patch_norefine.py`). The midpoint note below says the 6 extra detections "contradict" the paper's claim. Looking at which constants were flagged showed that 5 of the 6 were array lengths or indices, not the secret. Only one, a hard-coded PBE password in a `char[]`, is a real miss caused by refinement. Also, the full ablation gave exactly the same result as the earlier count of the "removed" group. Our guess that RI-III drops some alerts before they reach that group was wrong for the paper-era code.
3. Discrepancy matrix. Dropped, because Daniel left the course. `docs/results.md` still compares the tools file by file on the custom suite.

## Original plan (midpoint, November 5)

Reproducing the paper's numbers is only half of the project. On top of that we are adding three things:

1. A custom test suite of 15 Java files (Abdelrahman leads this).
2. A refinement ablation study (Mark).
3. A discrepancy matrix comparing CryptoGuard and SpotBugs (Daniel).

All three use the same harness and scoring as the baseline, so the results can be compared directly.

## 1. Custom test suite

We are expanding our first sample files into 15 targeted test cases. Some cover common JCA misuse patterns (static IV reuse, insecure cipher modes, weak key derivation). The rest target places where the paper itself says CryptoGuard will get it wrong (Section 7), or where our baseline run already found a miss. Before running each file we write down what we expect each tool to do and why, so every result either confirms or contradicts something specific.

Of the 15 files, 9 contain a misuse and 6 are secure versions. The benchmark has only 16 secure cases out of 112, so these extra secure files give us a better check on false alarms.

Files go in `custom_tests/src/custom/` and their labels go in `custom_tests/ground_truth_custom.csv`.

### Pilot (done November 4)

We wrote three files first to make sure the whole pipeline works end to end.

| File | What it does | What we expected from CryptoGuard | CG-2019 | CG-2020 | FindSecBugs |
|---|---|---|---|---|---|
| `PilotClippedHexKey` | Hard-coded AES key passed through `DatatypeConverter.parseHexBinary("6A5B...")`. This is the paper's own Section 7 example | Missed | Missed | Missed | Missed |
| `PilotInfeasibleIteration` | Iteration count set to 0, but always overwritten with 10000 before it is used (the jackrabbit-oak example from the paper) | False alarm | False alarm | False alarm | No alert |
| `PilotSecureKey` | Key generated with `KeyGenerator` and `init(256)` | No alert | False alarm | No alert | No alert |

The first two came out as the paper predicts. The third one was a surprise: CG-2019 treats the key size `256` as a hard-coded key. The newer version doesn't do this.

### Remaining 12 files

| # | What the file does | Rule | Expected CryptoGuard result | Why |
|---|---|---|---|---|
| 1 | Hard-coded key set through a setter on a holder object, then used in `SecretKeySpec` | 1 | Missed | Paper Section 5.2 gives this as an RI-I false negative |
| 2 | Hard-coded key decoded with `Base64.getDecoder().decode("...")` | 1 | Missed | Same clipping issue as the hex pilot |
| 3 | `"defaultkey".getBytes()` passed to `SecretKeySpec`, with and without `Arrays.copyOf` in between | 1 | Not sure | Both versions miss the benchmark case built this way (our failure trace) |
| 4 | Subclass of `SSLSocketFactory` that creates sockets with no hostname check | 6 | Missed | Paper says subclasses of SSLSocketFactory are ignored |
| 5 | `KeyPairGenerator.getInstance("RSA")` in one method and `initialize(1024)` in another | 15 | Missed | Rule 15 only looks inside one method |
| 6 | Static IV built in a helper method and reused for several encryptions | 12 | Not sure | Benchmark case `StaticInitializationVectorABICase2` is missed |
| 7 | Low PBE iteration count passed through two method calls (weak key derivation) | 13 | Missed | Benchmark case `LessThan1000IterationPBEABICase2` is missed |
| 8 | `SecureRandom.setSeed` with a constant from a static final field | 8 | Detected | Control case for rule 8 |
| 9 | `"AES/ECB/PKCS5Padding"` picked from a config string through a `switch` (insecure cipher mode) | 11 | Detected | Control case for rule 11 |
| 10 | Secure version of #1, key from `KeyGenerator` | 1 | No alert | False-alarm check |
| 11 | Secure version of #4, `HttpsURLConnection` with the default hostname verifier | 6 | No alert | False-alarm check |
| 12 | Secure version of #7, at least 10000 iterations passed through two calls | 13 | No alert | False-alarm check |

## 2. Refinement ablation

CryptoGuard has five "refinement insights" (RI-I to RI-V) that remove alerts it considers false. The paper says they remove 76 to 80 percent of alerts on real projects and that every removed alert was a false positive. We will run CryptoGuard with the refinements on and off, on the benchmark and on our custom suite, and check both parts of that claim.

We already have a first result without changing any code. CG-2019 prints the alerts that refinement removed in a separate group, so we can count them. On the benchmark it removed 67 of 160 alerts (42 percent). If those alerts had been kept, up to 6 more vulnerable cases would have been detected and 1 secure case would have become a false alarm. That contradicts the claim that every removed alert is a false positive, at least on this benchmark. For a complete ablation we need a modified build with the refinement checks switched off, because one of the refinements (RI-III) drops alerts before they reach that separate group.

## 3. Discrepancy matrix

For every benchmark case and custom test we will record what each tool reported. Then we will list the cases where CryptoGuard and SpotBugs disagree and mark each disagreement as a false positive or a false negative. The cases are grouped by vulnerability type using CWE (for example CWE-327 for broken or risky crypto and CWE-321 for hard-coded keys). The harness already writes the inputs for this: `scored/alerts.csv` and `scored/per_case.csv` for every tool.

## Out of scope

We are not changing CryptoGuard's detection logic, apart from the switch needed for the ablation. If we have time, we may try one small real project (Apache Commons Crypto) as a spot check, but that is optional.
