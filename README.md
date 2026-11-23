# High-Precision Evaluation of Cryptographic API Misuses using CryptoGuard

ECE 424 / ECE 539, Fall 2026, Rutgers University
Abdelrahman Naser and Mark Tymoshenko (Daniel Mulraney was part of the team until he left the course)

Final results are in `docs/results.md`. The midpoint checkpoint submission is `CHECKPOINT.md`.

We are testing the claims in Rahaman et al., "CryptoGuard: High Precision Detection of Cryptographic Vulnerabilities in Massive-sized Java Projects" (ACM CCS 2019, arXiv:1806.06881). We run CryptoGuard and SpotBugs/FindSecBugs on the CryptoAPI-Bench benchmark and on our own test files, and compare what we get with what the paper reports.

## Main findings

- No false alarms from either CryptoGuard version on the 16 secure benchmark cases, so the paper's precision claim holds. Recall is lower than reported: 77 of 96 (paper-era code) and 82 of 96 (current release), against the paper's 85.
- The paper-era code misses every hard-coded key case in the benchmark, because each one passes the key through `Arrays.copyOf` and the tool loses it there.
- With refinement turned off, the paper-era code finds 6 more cases, but 5 of those are flagged only for an array length or index. The one real loss from refinement is a hard-coded PBE password stored as a `char[]`.
- On our 15-file custom suite, both CryptoGuard versions find 12 of 13 misuses and FindSecBugs finds 10. The CryptoGuard miss is a bug: RSA key size is never checked inside a method with an array parameter, such as `main(String[] args)`.

## Tools and versions

| Tool | Version |
|---|---|
| CryptoGuard (paper era, "CG-2019") | `ccs-submission` branch, commit `4097f921`, January 2019 |
| CG-2019 with refinement off | the same code patched by `harness/patch_norefine.py`, run with `-Dcg.norefine=true` |
| CryptoGuard (current, "CG-2020") | release v04.05.03, commit `92551eeb` |
| SpotBugs + FindSecBugs | SpotBugs 4.6.0, FindSecBugs 1.12.0 |
| CryptoAPI-Bench | commit `734aecb`, the 112-case version used in the paper |

All versions are pinned in `harness/pins.env`.

## Running everything

You need Ubuntu 22.04 or 24.04. Setup installs everything else, and you don't need Maven Central or Gradle. The whole thing takes about 15 minutes.

```bash
git clone https://github.com/speed7861/intro-to-network-security-2026-fall.git
cd intro-to-network-security-2026-fall
bash harness/setup.sh          # installs JDK 8 + 21 and Java libraries, downloads the pinned tools and benchmark into ext/
bash harness/build.sh          # builds the benchmark jar, the custom test jar and all CryptoGuard builds into build/
bash harness/run_all.sh myrun  # runs every tool on the benchmark and the custom tests, scores the results
bash harness/sanity.sh myrun   # sanity checks S1 to S7
bash harness/probes.sh myrun   # root-cause probes
```

Results go in `runs/myrun/`. For each tool, `scored/summary.md` has the precision and recall tables and `scored/per_case.csv` has one row per test case. Each run also writes a manifest with the exact command, versions, exit code, run time and file hashes. The custom test results are in the `custom_<tool>` folders.

To run one tool on any jar:

```bash
bash harness/run_tool.sh cg2020 path/to/app.jar runs/adhoc/
```

### Running SpotBugs by hand on the custom tests

This is the quick check we started with, before the full harness existed. After `setup.sh`:

```bash
export PATH=/usr/lib/jvm/java-8-openjdk-amd64/bin:$PATH   # SpotBugs and the tests need Java 8
mkdir -p build/manual
javac -encoding UTF-8 -d build/manual $(find custom_tests -name '*.java')
bash ext/tools/fsb/findsecbugs.sh -html -output logs/spotbugs_manual.html build/manual
```

The full harness does the same thing but scores the output against ground truth.

## Results on the benchmark

From `runs/20261123_final` (112 test cases, 96 vulnerable and 16 secure). The November 4 baseline run gave the same numbers.

| | Detected | False alarms | Missed | Precision | Recall |
|---|---|---|---|---|---|
| Paper, CryptoGuard | 85 | 0 | 11 | 100% | 88.5% |
| Our run, CG-2019 | 77 | 0 | 19 | 100% | 80.2% |
| Our run, CG-2019 with refinement off | 83 | 1 | 13 | 98.8% | 86.5% |
| Our run, CG-2020 | 82 | 0 | 14 | 100% | 85.4% |
| Paper, SpotBugs 3.0.1 | 26 | 11 | 70 | 70.3% | 27.1% |
| Our run, FindSecBugs 1.12.0 | 21 | 0 | 75 | 100% | 21.9% |

Results on the custom suite and the root-cause analysis are in `docs/results.md`.

## Repository layout

```
harness/       scripts: setup, build, run, score, sanity checks, probes, refinement patch; pinned versions in pins.env
data/          ground truth for the 112 benchmark cases
custom_tests/  Abdul's 15 test files, our 3 pilot files (src/custom/pilot), labels, Abdul's SpotBugs report
probes/        small variants of the missed cases, used to find out why they are missed
runs/          one folder per run: raw tool output, manifests, scored results, checksums
docs/          results, protocol, contribution plan, team progress
logs/LOG.md    lab notebook
```

## Notes

This project only does static analysis of public benchmark code and our own small test files. Nothing is run against live systems.

CryptoGuard is GPL-3.0 licensed. It is downloaded during setup and not stored in this repo. The same goes for CryptoAPI-Bench. `harness/patch_norefine.py` changes a downloaded copy at build time.
