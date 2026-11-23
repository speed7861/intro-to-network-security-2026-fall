# Team progress (final, November 23, 2026)

Each of us commits our own work, so `git log --author="<name>"` shows who did what.

## Abdelrahman Naser: custom test suite and SpotBugs evaluation

Experiments: E3 (SpotBugs/FindSecBugs evaluation) and E4 (custom test suite).

- Set up SpotBugs with the FindSecBugs plugin on his own machine and confirmed bytecode scanning works.
- Wrote the 15-file custom test suite (`custom_tests/*.java`, committed November 23): 13 misuse patterns (hard-coded key, MD5, SHA-1, ECB mode, AES defaulting to ECB, static IV, DES, `java.util.Random` for a key, fixed `SecureRandom` seed, 512-bit RSA, hard-coded keystore password, low PBE iteration count, and a key hidden behind `StringBuilder.reverse()`) and 2 secure versions (AES-GCM, SHA-256).
- Ran SpotBugs with FindSecBugs on the suite and committed the report (`custom_tests/spotbugs_custom_report.txt` and `.html`). The harness's own FindSecBugs run agrees with his report on every file.
- His `SmallRSAKeyTest10` exposed a bug in CryptoGuard that the benchmark never triggers (see `docs/results.md`, section 4).

## Mark Tymoshenko: CryptoGuard setup, refinement ablation and root-cause analysis

Experiments: E1 (CryptoGuard on the benchmark and the custom tests), E2 (refinement ablation) and E6 (root-cause probes).

- Got both CryptoGuard versions building without Gradle or Maven Central, and found the paper-era CryptoGuard commit and the 112-case benchmark commit in their git histories.
- Wrote the harness (`setup.sh`, `build.sh`, `run_tool.sh`, `run_all.sh`, `sanity.sh`, `probes.sh`, `ground_truth.py`, `score.py`, `patch_norefine.py`).
- Ran the benchmark baseline (November 4) and the final run (November 23), both with sanity checks.
- Wrote the 3 pilot test files and added labels for Abdul's 15 files so the harness scores them.
- Built a version of the paper-era CryptoGuard with a switch that turns refinement off, checked that it matches the original when the switch is off, and ran the ablation.
- Traced the misses to their causes with the probe files in `probes/`: `Arrays.copyOf` in CG-2019, local string variables in CG-2020, and the array-parameter bug in rule 15.
- Wrote `docs/results.md`.

## Daniel Mulraney

Daniel left the course partway through the semester. Before leaving he drafted the evaluation table schema and the CWE mapping (CWE-327, CWE-321) described in the midpoint write-up. That work was never committed to the repo, and the discrepancy matrix he was going to build (experiment E5) was dropped. `docs/results.md` still compares CryptoGuard and FindSecBugs file by file on the custom suite, but not as a full CWE matrix.
