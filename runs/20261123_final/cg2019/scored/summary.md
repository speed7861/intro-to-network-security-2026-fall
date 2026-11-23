# Scored run: `cg2019`

Cases: 112 (96 positive / 16 negative). Alerts: 160 total, 91 on-target, 18 not attributable to a test file.

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| **All 112 cases** | 96 | 77 | 0 | 19 | 16 | 100.0% | 80.2% |
| interprocedural | 42 | 33 | 0 | 9 | 0 | 100.0% | 78.6% |
| field_sensitive | 20 | 17 | 0 | 3 | 0 | 100.0% | 85.0% |
| basic | 25 | 20 | 0 | 5 | 0 | 100.0% | 80.0% |
| correct | 0 | 0 | 0 | 0 | 14 | — | — |
| fp_test | 9 | 7 | 0 | 2 | 2 | 100.0% | 77.8% |

## Paper Table 3 analogue (6 shared rules: 1, 2, 3, 11, 14, 16)

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| basic (+correct) | 14 | 12 | 0 | 2 | 6 | 100.0% | 85.7% |
| advanced | 42 | 36 | 0 | 6 | 2 | 100.0% | 85.7% |

## Per rule vs. paper Table 7

| Rule | GTP (ours/paper) | TP ours | TP paper CG | TP paper SpotBugs | FP ours | FN ours |
|---|---|---|---|---|---|---|
| 1 | 6/5 | 0 | 5 | 2 | 0 | 6 |
| 2 | 6/6 | 4 | 6 | 3 | 0 | 2 |
| 3 | 4/5 | 4 | 5 | 2 | 0 | 0 |
| 4 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 5 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 6 | 4/4 | 4 | 4 | — | 0 | 0 |
| 7 | 4/4 | 4 | 4 | — | 0 | 0 |
| 8 | 10/10 | 5 | 5 | — | 0 | 5 |
| 9 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 10 | 5/5 | 3 | 3 | — | 0 | 2 |
| 11 | 4/4 | 4 | 4 | 1 | 0 | 0 |
| 12 | 6/6 | 4 | 4 | 6 | 0 | 2 |
| 13 | 5/5 | 4 | 4 | — | 0 | 1 |
| 14 | 20/20 | 20 | 20 | 5 | 0 | 0 |
| 15 | 3/3 | 2 | 2 | 0 | 0 | 1 |
| 16 | 16/16 | 16 | 16 | 4 | 0 | 0 |

## Refinement ablation (partial — see docs/protocol.md §E2)

Alerts kept: 93; alerts moved to 'other sources' by refinement: 67 (41.9% reduction; paper reports 76–80% on real projects).

Case-level if refined-out alerts were reported: | no-refinement | 96 | 83 | 1 | 13 | 15 | 98.8% | 86.5% |

## Misses and false alarms

- **FN** `InsecureAsymmetricCipherABICase2` (rule 15, interprocedural)
- **FN** `LessThan1000IterationPBEABICase2` (rule 13, interprocedural)
- **FN** `PredictableCryptographicKeyABHCase1` (rule 1, fp_test)
- **FN** `PredictableCryptographicKeyABHCase2` (rule 1, fp_test)
- **FN** `PredictableCryptographicKeyABICase1` (rule 1, interprocedural)
- **FN** `PredictableCryptographicKeyABICase2` (rule 1, interprocedural)
- **FN** `PredictableCryptographicKeyABSCase1` (rule 1, field_sensitive)
- **FN** `PredictableCryptographicKeyBBCase1` (rule 1, basic)
- **FN** `PredictablePBEPasswordABICase2` (rule 2, interprocedural)
- **FN** `PredictablePBEPasswordBBCase2` (rule 2, basic) — would be detected without refinement
- **FN** `PredictableSeedsABICase3` (rule 8, interprocedural)
- **FN** `PredictableSeedsABICase4` (rule 8, interprocedural) — would be detected without refinement
- **FN** `PredictableSeedsABSCase1` (rule 8, field_sensitive)
- **FN** `PredictableSeedsABSCase2` (rule 8, field_sensitive) — would be detected without refinement
- **FN** `PredictableSeedsBBCase2` (rule 8, basic) — would be detected without refinement
- **FN** `StaticInitializationVectorABICase2` (rule 12, interprocedural) — would be detected without refinement
- **FN** `StaticInitializationVectorBBCase1` (rule 12, basic)
- **FN** `StaticSaltsABICase2` (rule 10, interprocedural) — would be detected without refinement
- **FN** `StaticSaltsBBCase1` (rule 10, basic)
