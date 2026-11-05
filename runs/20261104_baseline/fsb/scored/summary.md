# Scored run: `fsb`

Cases: 112 (96 positive / 16 negative). Alerts: 70 total, 25 on-target, 0 not attributable to a test file.

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| **All 112 cases** | 96 | 21 | 0 | 75 | 16 | 100.0% | 21.9% |
| basic | 25 | 13 | 0 | 12 | 0 | 100.0% | 52.0% |
| correct | 0 | 0 | 0 | 0 | 14 | — | — |
| interprocedural | 42 | 5 | 0 | 37 | 0 | 100.0% | 11.9% |
| field_sensitive | 20 | 1 | 0 | 19 | 0 | 100.0% | 5.0% |
| fp_test | 9 | 2 | 0 | 7 | 2 | 100.0% | 22.2% |

## Paper Table 3 analogue (6 shared rules: 1, 2, 3, 11, 14, 16)

| Slice | GTP | TP | FP | FN | TN | Precision | Recall |
|---|---|---|---|---|---|---|---|
| basic (+correct) | 14 | 9 | 0 | 5 | 6 | 100.0% | 64.3% |
| advanced | 42 | 3 | 0 | 39 | 2 | 100.0% | 7.1% |

## Per rule vs. paper Table 7

| Rule | GTP (ours/paper) | TP ours | TP paper CG | TP paper SpotBugs | FP ours | FN ours |
|---|---|---|---|---|---|---|
| 1 | 6/5 | 1 | 5 | 2 | 0 | 5 |
| 2 | 6/6 | 2 | 6 | 3 | 0 | 4 |
| 3 | 4/5 | 2 | 5 | 2 | 0 | 2 |
| 4 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 5 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 6 | 4/4 | 0 | 4 | — | 0 | 4 |
| 7 | 4/4 | 0 | 4 | — | 0 | 4 |
| 8 | 10/10 | 0 | 5 | — | 0 | 10 |
| 9 | 1/1 | 1 | 1 | 1 | 0 | 0 |
| 10 | 5/5 | 0 | 3 | — | 0 | 5 |
| 11 | 4/4 | 1 | 4 | 1 | 0 | 3 |
| 12 | 6/6 | 6 | 4 | 6 | 0 | 0 |
| 13 | 5/5 | 0 | 4 | — | 0 | 5 |
| 14 | 20/20 | 2 | 20 | 5 | 0 | 18 |
| 15 | 3/3 | 0 | 2 | 0 | 0 | 3 |
| 16 | 16/16 | 4 | 16 | 4 | 0 | 12 |

## Misses and false alarms

- **FN** `BrokenCryptoABICase1` (rule 14, interprocedural)
- **FN** `BrokenCryptoABICase10` (rule 14, interprocedural)
- **FN** `BrokenCryptoABICase2` (rule 14, interprocedural)
- **FN** `BrokenCryptoABICase3` (rule 14, interprocedural)
- **FN** `BrokenCryptoABICase4` (rule 14, interprocedural)
- **FN** `BrokenCryptoABICase6` (rule 14, interprocedural)
- **FN** `BrokenCryptoABICase7` (rule 14, interprocedural)
- **FN** `BrokenCryptoABICase8` (rule 14, interprocedural)
- **FN** `BrokenCryptoABICase9` (rule 14, interprocedural)
- **FN** `BrokenCryptoABSCase1` (rule 14, field_sensitive)
- **FN** `BrokenCryptoABSCase2` (rule 14, field_sensitive)
- **FN** `BrokenCryptoABSCase3` (rule 14, field_sensitive)
- **FN** `BrokenCryptoABSCase4` (rule 14, field_sensitive)
- **FN** `BrokenCryptoABSCase5` (rule 14, field_sensitive)
- **FN** `BrokenCryptoBBCase2` (rule 14, basic)
- **FN** `BrokenCryptoBBCase3` (rule 14, basic)
- **FN** `BrokenCryptoBBCase4` (rule 14, basic)
- **FN** `BrokenCryptoBBCase5` (rule 14, basic)
- **FN** `BrokenHashABICase1` (rule 16, interprocedural)
- **FN** `BrokenHashABICase2` (rule 16, interprocedural)
- **FN** `BrokenHashABICase3` (rule 16, interprocedural)
- **FN** `BrokenHashABICase4` (rule 16, interprocedural)
- **FN** `BrokenHashABICase5` (rule 16, interprocedural)
- **FN** `BrokenHashABICase6` (rule 16, interprocedural)
- **FN** `BrokenHashABICase7` (rule 16, interprocedural)
- **FN** `BrokenHashABICase8` (rule 16, interprocedural)
- **FN** `BrokenHashABSCase1` (rule 16, field_sensitive)
- **FN** `BrokenHashABSCase2` (rule 16, field_sensitive)
- **FN** `BrokenHashABSCase3` (rule 16, field_sensitive)
- **FN** `BrokenHashABSCase4` (rule 16, field_sensitive)
- **FN** `EcbInSymmCryptoABICase1` (rule 11, interprocedural)
- **FN** `EcbInSymmCryptoABICase2` (rule 11, interprocedural)
- **FN** `EcbInSymmCryptoABSCase1` (rule 11, field_sensitive)
- **FN** `HttpProtocolABICase1` (rule 7, interprocedural)
- **FN** `HttpProtocolABICase2` (rule 7, interprocedural)
- **FN** `HttpProtocolABSCase1` (rule 7, field_sensitive)
- **FN** `HttpProtocolBBCase1` (rule 7, basic)
- **FN** `ImproperSocketManualHostABICase1` (rule 6, interprocedural)
- **FN** `ImproperSocketManualHostABICase2` (rule 6, interprocedural)
- **FN** `ImproperSocketManualHostABSCase1` (rule 6, field_sensitive)
- **FN** `ImproperSocketManualHostBBCase1` (rule 6, basic)
- **FN** `InsecureAsymmetricCipherABICase1` (rule 15, interprocedural)
- **FN** `InsecureAsymmetricCipherABICase2` (rule 15, interprocedural)
- **FN** `InsecureAsymmetricCipherBBCase1` (rule 15, basic)
- **FN** `LessThan1000IterationPBEABHCase1` (rule 13, fp_test)
- **FN** `LessThan1000IterationPBEABICase1` (rule 13, interprocedural)
- **FN** `LessThan1000IterationPBEABICase2` (rule 13, interprocedural)
- **FN** `LessThan1000IterationPBEABSCase1` (rule 13, field_sensitive)
- **FN** `LessThan1000IterationPBEBBCase1` (rule 13, basic)
- **FN** `PredictableCryptographicKeyABHCase1` (rule 1, fp_test)
- **FN** `PredictableCryptographicKeyABHCase2` (rule 1, fp_test)
- **FN** `PredictableCryptographicKeyABICase1` (rule 1, interprocedural)
- **FN** `PredictableCryptographicKeyABSCase1` (rule 1, field_sensitive)
- **FN** `PredictableCryptographicKeyBBCase1` (rule 1, basic)
- **FN** `PredictableKeyStorePasswordABICase1` (rule 3, interprocedural)
- **FN** `PredictableKeyStorePasswordABSCase1` (rule 3, field_sensitive)
- **FN** `PredictablePBEPasswordABHCase2` (rule 2, fp_test)
- **FN** `PredictablePBEPasswordABICase1` (rule 2, interprocedural)
- **FN** `PredictablePBEPasswordABICase2` (rule 2, interprocedural)
- **FN** `PredictablePBEPasswordABSCase1` (rule 2, field_sensitive)
- **FN** `PredictableSeedsABHCase2` (rule 8, fp_test)
- **FN** `PredictableSeedsABHCase4` (rule 8, fp_test)
- **FN** `PredictableSeedsABICase1` (rule 8, interprocedural)
- **FN** `PredictableSeedsABICase2` (rule 8, interprocedural)
- **FN** `PredictableSeedsABICase3` (rule 8, interprocedural)
- **FN** `PredictableSeedsABICase4` (rule 8, interprocedural)
- **FN** `PredictableSeedsABSCase1` (rule 8, field_sensitive)
- **FN** `PredictableSeedsABSCase2` (rule 8, field_sensitive)
- **FN** `PredictableSeedsBBCase1` (rule 8, basic)
- **FN** `PredictableSeedsBBCase2` (rule 8, basic)
- **FN** `StaticSaltsABHCase1` (rule 10, fp_test)
- **FN** `StaticSaltsABICase1` (rule 10, interprocedural)
- **FN** `StaticSaltsABICase2` (rule 10, interprocedural)
- **FN** `StaticSaltsABSCase1` (rule 10, field_sensitive)
- **FN** `StaticSaltsBBCase1` (rule 10, basic)
