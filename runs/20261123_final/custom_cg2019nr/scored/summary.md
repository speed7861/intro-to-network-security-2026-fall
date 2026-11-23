# Scored run: `cg2019nr`

Cases: 18 (14 positive / 4 negative). Alerts: 47 total, 30 on-target, 5 not attributable to a test file.

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| **All 18 cases** | 14 | 12 | 2 | 2 | 2 | 85.7% | 85.7% |
| pilot_fn_probe | 1 | 0 | 0 | 1 | 0 | — | 0.0% |
| pilot_fp_probe | 0 | 0 | 1 | 0 | 0 | 0.0% | — |
| pilot_negative | 0 | 0 | 1 | 0 | 0 | 0.0% | — |
| suite_misuse | 13 | 12 | 0 | 1 | 0 | 100.0% | 92.3% |
| suite_secure | 0 | 0 | 0 | 0 | 2 | — | — |

## Paper Table 3 analogue (6 shared rules: 1, 2, 3, 11, 14, 16)

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| basic (+correct) | 0 | 0 | 0 | 0 | 0 | — | — |
| advanced | 9 | 8 | 1 | 1 | 2 | 88.9% | 88.9% |

## Per rule vs. paper Table 7

| Rule | GTP (ours/paper) | TP ours | TP paper CG | TP paper SpotBugs | FP ours | FN ours |
|---|---|---|---|---|---|---|
| 1 | 3/5 | 2 | 5 | 2 | 1 | 1 |
| 2 | 0/6 | 0 | 6 | 3 | 0 | 0 |
| 3 | 1/5 | 1 | 5 | 2 | 0 | 0 |
| 4 | 0/1 | 0 | 1 | 1 | 0 | 0 |
| 5 | 0/1 | 0 | 1 | 1 | 0 | 0 |
| 6 | 0/4 | 0 | 4 | — | 0 | 0 |
| 7 | 0/4 | 0 | 4 | — | 0 | 0 |
| 8 | 1/10 | 1 | 5 | — | 0 | 0 |
| 9 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 10 | 0/5 | 0 | 3 | — | 0 | 0 |
| 11 | 2/4 | 2 | 4 | 1 | 0 | 0 |
| 12 | 1/6 | 1 | 4 | 6 | 0 | 0 |
| 13 | 1/5 | 1 | 4 | — | 1 | 0 |
| 14 | 1/20 | 1 | 20 | 5 | 0 | 0 |
| 15 | 1/3 | 0 | 2 | 0 | 0 | 1 |
| 16 | 2/16 | 2 | 16 | 4 | 0 | 0 |

## Refinement ablation (partial — see docs/protocol.md §E2)

Alerts kept: 44; alerts moved to 'other sources' by refinement: 3 (6.4% reduction; paper reports 76–80% on real projects).

Case-level if refined-out alerts were reported: | no-refinement | 14 | 12 | 2 | 2 | 2 | 85.7% | 85.7% |

## Misses and false alarms

- **FN** `PilotClippedHexKey` (rule 1, pilot_fn_probe)
- **FP** `PilotInfeasibleIteration` (rule 13, pilot_fp_probe)
- **FP** `PilotSecureKey` (rule 1, pilot_negative)
- **FN** `SmallRSAKeyTest10` (rule 15, suite_misuse)
