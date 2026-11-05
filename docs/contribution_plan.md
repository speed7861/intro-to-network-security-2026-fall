# Bounded contribution plan

**What we add beyond the baseline:** a small, labelled test suite (15 Java files) where every file targets a failure mode the paper itself predicts in §7 or that our baseline exposed, run through all three tools with the same harness and scoring. Each file has a stated *prediction* written before the run, so every result is a confirm/refute of a specific claim rather than a score.

Owner of the suite: **Abdelrahman** (design + files). Runs and analysis use the shared harness (`custom_tests/` → `harness/run_all.sh`). Labels live in `custom_tests/ground_truth_custom.csv` (same columns as the benchmark ground truth).

## Pilot (done 2026-11-04, validates the pipeline)

Three probes were written to prove the custom-test path works end to end. All three predictions from the paper held:

| Probe | Pattern | Prediction | CG-2019 | CG-2020 | FindSecBugs |
|---|---|---|---|---|---|
| P1 `PilotClippedHexKey` | constant AES key via `DatatypeConverter.parseHexBinary("6A5B…")` (paper §7 example) | **FN** (RI-II treats it as a pseudo-influence) | FN ✔ | FN ✔ | FN |
| P2 `PilotInfeasibleIteration` | `iteration = 0` overwritten to 10000 before use (paper's jackrabbit-oak example) | **FP** (path insensitivity) | FP ✔ | FP ✔ | TN |
| P3 `PilotSecureKey` | key from `KeyGenerator`, `init(256)` | TN | **FP** ✘ (flags `256` as a constant key) | TN | TN |

P3 is a new finding: CG-2019 reports the key-size argument as a hard-coded key; CG-2020 fixes it.

## Planned 12 files (targets → why)

| # | Target | Rule | Expected CG result | Source of prediction |
|---|---|---|---|---|
| 1 | Constant key through a setter on a holder object (`holder.setKey("abcd")` → `SecretKeySpec`) | 1 | FN | §5.2, RI-I false negative example |
| 2 | Constant key through `Base64.getDecoder().decode("...")` | 1 | FN | §7 clipping, generalises P1 |
| 3 | `String k = "defaultkey"; k.getBytes()` → `Arrays.copyOf` → `SecretKeySpec` in one method, plus a variant without `copyOf` | 1 | ? | baseline failure trace (S4): both builds miss `PredictableCryptographicKeyBBCase1` |
| 4 | `SSLSocketFactory` subclass creating sockets, no hostname check | 6 | FN | §7: subclasses of SSLSocketFactory are ignored |
| 5 | `KeyPairGenerator.getInstance("RSA")` in one method, `initialize(1024)` in another | 15 | FN | Rule 15 uses intra-procedural forward slicing only |
| 6 | Constant IV built in a helper method that returns `byte[]` | 12 | TP/FN | baseline FN `StaticInitializationVectorABICase2` |
| 7 | PBE iterations passed through two method calls | 13 | FN | baseline FN `LessThan1000IterationPBEABICase2` |
| 8 | Constant `SecureRandom.setSeed(long)` from a static final field | 8 | TP | control for rule 8 |
| 9 | MD5 chosen by a `switch` on a config string (both branches constant) | 16 | TP | control |
| 10 | Secure twin of #1 (key from `KeyGenerator`) | 1 | TN | FP check for RI-I |
| 11 | Secure twin of #4 (`HttpsURLConnection` with default verifier) | 6 | TN | FP check |
| 12 | Secure twin of #7 (iterations ≥ 10000 through two calls) | 13 | TN | FP check |

That gives 15 files total (3 pilot + 12): 9 misuse, 6 secure — enough negatives to measure false positives, which the benchmark alone barely tests (only 16 of 112 cases are secure).

## Metrics and output

Per-file outcome for each tool, P/R over the 15 files, and for every miss a one-line cause tied to a paper mechanism (clipping depth, RI-I…RI-V, path insensitivity, intra-procedural slicing). Mark re-runs the suite with refinements disabled (E2) to show which misses the refinements cause.

## Out of scope

No changes to CryptoGuard's detection logic beyond the ablation switch; no real-world projects beyond an optional small spot check (Apache Commons Crypto) if time allows.
