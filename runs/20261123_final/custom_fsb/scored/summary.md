# Scored run: `fsb`

Cases: 18 (14 positive / 4 negative). Alerts: 17 total, 11 on-target, 0 not attributable to a test file.

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| **All 18 cases** | 14 | 10 | 0 | 4 | 4 | 100.0% | 71.4% |
| pilot_fn_probe | 1 | 0 | 0 | 1 | 0 | — | 0.0% |
| pilot_fp_probe | 0 | 0 | 0 | 0 | 1 | — | — |
| pilot_negative | 0 | 0 | 0 | 0 | 1 | — | — |
| suite_misuse | 13 | 10 | 0 | 3 | 0 | 100.0% | 76.9% |
| suite_secure | 0 | 0 | 0 | 0 | 2 | — | — |

## Paper Table 3 analogue (6 shared rules: 1, 2, 3, 11, 14, 16)

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| basic (+correct) | 0 | 0 | 0 | 0 | 0 | — | — |
| advanced | 9 | 7 | 0 | 2 | 3 | 100.0% | 77.8% |

## Per rule vs. paper Table 7

| Rule | GTP (ours/paper) | TP ours | TP paper CG | TP paper SpotBugs | FP ours | FN ours |
|---|---|---|---|---|---|---|
| 1 | 3/5 | 1 | 5 | 2 | 0 | 2 |
| 2 | 0/6 | 0 | 6 | 3 | 0 | 0 |
| 3 | 1/5 | 1 | 5 | 2 | 0 | 0 |
| 4 | 0/1 | 0 | 1 | 1 | 0 | 0 |
| 5 | 0/1 | 0 | 1 | 1 | 0 | 0 |
| 6 | 0/4 | 0 | 4 | — | 0 | 0 |
| 7 | 0/4 | 0 | 4 | — | 0 | 0 |
| 8 | 1/10 | 0 | 5 | — | 0 | 1 |
| 9 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 10 | 0/5 | 0 | 3 | — | 0 | 0 |
| 11 | 2/4 | 2 | 4 | 1 | 0 | 0 |
| 12 | 1/6 | 1 | 4 | 6 | 0 | 0 |
| 13 | 1/5 | 0 | 4 | — | 0 | 1 |
| 14 | 1/20 | 1 | 20 | 5 | 0 | 0 |
| 15 | 1/3 | 1 | 2 | 0 | 0 | 0 |
| 16 | 2/16 | 2 | 16 | 4 | 0 | 0 |

## Misses and false alarms

- **FN** `PilotClippedHexKey` (rule 1, pilot_fn_probe)
- **FN** `StaticSeedSecureRandomTest9` (rule 8, suite_misuse)
- **FN** `LowIterationPBETest12` (rule 13, suite_misuse)
- **FN** `ObfuscatedKeySliceTest13` (rule 1, suite_misuse)
