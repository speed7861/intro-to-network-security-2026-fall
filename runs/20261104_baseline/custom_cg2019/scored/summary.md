# Scored run: `cg2019`

Cases: 3 (1 positive / 2 negative). Alerts: 6 total, 2 on-target, 2 not attributable to a test file.

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| **All 3 cases** | 1 | 0 | 2 | 1 | 0 | 0.0% | 0.0% |
| basic | 0 | 0 | 0 | 0 | 0 | — | — |
| correct | 0 | 0 | 0 | 0 | 0 | — | — |
| interprocedural | 0 | 0 | 0 | 0 | 0 | — | — |
| field_sensitive | 0 | 0 | 0 | 0 | 0 | — | — |
| fp_test | 0 | 0 | 0 | 0 | 0 | — | — |

## Paper Table 3 analogue (6 shared rules: 1, 2, 3, 11, 14, 16)

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| basic (+correct) | 0 | 0 | 0 | 0 | 0 | — | — |
| advanced | 1 | 0 | 1 | 1 | 0 | 0.0% | 0.0% |

## Per rule vs. paper Table 7

| Rule | GTP (ours/paper) | TP ours | TP paper CG | TP paper SpotBugs | FP ours | FN ours |
|---|---|---|---|---|---|---|
| 1 | 1/5 | 0 | 5 | 2 | 1 | 1 |
| 2 | 0/6 | 0 | 6 | 3 | 0 | 0 |
| 3 | 0/5 | 0 | 5 | 2 | 0 | 0 |
| 4 | 0/1 | 0 | 1 | 1 | 0 | 0 |
| 5 | 0/1 | 0 | 1 | 1 | 0 | 0 |
| 6 | 0/4 | 0 | 4 | — | 0 | 0 |
| 7 | 0/4 | 0 | 4 | — | 0 | 0 |
| 8 | 0/10 | 0 | 5 | — | 0 | 0 |
| 9 | 0/1 | 0 | 1 | 1 | 0 | 0 |
| 10 | 0/5 | 0 | 3 | — | 0 | 0 |
| 11 | 0/4 | 0 | 4 | 1 | 0 | 0 |
| 12 | 0/6 | 0 | 4 | 6 | 0 | 0 |
| 13 | 0/5 | 0 | 4 | — | 1 | 0 |
| 14 | 0/20 | 0 | 20 | 5 | 0 | 0 |
| 15 | 0/3 | 0 | 2 | 0 | 0 | 0 |
| 16 | 0/16 | 0 | 16 | 4 | 0 | 0 |

## Refinement ablation (partial — see docs/protocol.md §E2)

Alerts kept: 2; alerts moved to 'other sources' by refinement: 4 (66.7% reduction; paper reports 76–80% on real projects).

Case-level if refined-out alerts were reported: | no-refinement | 1 | 0 | 2 | 1 | 0 | 0.0% | 0.0% |

## Misses and false alarms

- **FN** `PilotClippedHexKey` (rule 1, pilot_fn_probe)
- **FP** `PilotInfeasibleIteration` (rule 13, pilot_fp_probe)
- **FP** `PilotSecureKey` (rule 1, pilot_negative)
