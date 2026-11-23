# Scored run: `cg2020`

Cases: 112 (96 positive / 16 negative). Alerts: 87 total, 85 on-target, 2 not attributable to a test file.

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| **All 112 cases** | 96 | 82 | 0 | 14 | 16 | 100.0% | 85.4% |
| interprocedural | 42 | 34 | 0 | 8 | 0 | 100.0% | 81.0% |
| field_sensitive | 20 | 20 | 0 | 0 | 0 | 100.0% | 100.0% |
| basic | 25 | 21 | 0 | 4 | 0 | 100.0% | 84.0% |
| correct | 0 | 0 | 0 | 0 | 14 | — | — |
| fp_test | 9 | 7 | 0 | 2 | 2 | 100.0% | 77.8% |

## Paper Table 3 analogue (6 shared rules: 1, 2, 3, 11, 14, 16)

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| basic (+correct) | 14 | 12 | 0 | 2 | 6 | 100.0% | 85.7% |
| advanced | 42 | 39 | 0 | 3 | 2 | 100.0% | 92.9% |

## Per rule vs. paper Table 7

| Rule | GTP (ours/paper) | TP ours | TP paper CG | TP paper SpotBugs | FP ours | FN ours |
|---|---|---|---|---|---|---|
| 1 | 6/5 | 3 | 5 | 2 | 0 | 3 |
| 2 | 6/6 | 4 | 6 | 3 | 0 | 2 |
| 3 | 4/5 | 4 | 5 | 2 | 0 | 0 |
| 4 | 1/1 | 0 | 1 | 1 | 0 | 1 |
| 5 | 1/1 | 0 | 1 | 1 | 0 | 1 |
| 6 | 4/4 | 4 | 4 | — | 0 | 0 |
| 7 | 4/4 | 4 | 4 | — | 0 | 0 |
| 8 | 10/10 | 8 | 5 | — | 0 | 2 |
| 9 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 10 | 5/5 | 4 | 3 | — | 0 | 1 |
| 11 | 4/4 | 4 | 4 | 1 | 0 | 0 |
| 12 | 6/6 | 5 | 4 | 6 | 0 | 1 |
| 13 | 5/5 | 3 | 4 | — | 0 | 2 |
| 14 | 20/20 | 20 | 20 | 5 | 0 | 0 |
| 15 | 3/3 | 2 | 2 | 0 | 0 | 1 |
| 16 | 16/16 | 16 | 16 | 4 | 0 | 0 |

## Misses and false alarms

- **FN** `DummyCertValidationCase1` (rule 5, basic)
- **FN** `DummyHostNameVerifierCase1` (rule 4, basic)
- **FN** `InsecureAsymmetricCipherABICase2` (rule 15, interprocedural)
- **FN** `LessThan1000IterationPBEABHCase1` (rule 13, fp_test)
- **FN** `LessThan1000IterationPBEABICase2` (rule 13, interprocedural)
- **FN** `PredictableCryptographicKeyABHCase1` (rule 1, fp_test)
- **FN** `PredictableCryptographicKeyABICase1` (rule 1, interprocedural)
- **FN** `PredictableCryptographicKeyBBCase1` (rule 1, basic)
- **FN** `PredictablePBEPasswordABICase2` (rule 2, interprocedural)
- **FN** `PredictablePBEPasswordBBCase1` (rule 2, basic)
- **FN** `PredictableSeedsABICase3` (rule 8, interprocedural)
- **FN** `PredictableSeedsABICase4` (rule 8, interprocedural)
- **FN** `StaticInitializationVectorABICase2` (rule 12, interprocedural)
- **FN** `StaticSaltsABICase2` (rule 10, interprocedural)
