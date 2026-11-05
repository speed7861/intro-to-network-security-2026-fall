#!/usr/bin/env python3
"""Reconstruct case-level ground truth for the 112-case CryptoAPI-Bench (paper version).

The paper-era benchmark ships no label file, so labels are derived from the naming
convention and cross-checked against (a) the later CryptoAPI-Bench_details.xlsx and
(b) the GTP column of the paper's Table 7 (sanity check S1).

  <Rule>BBCase*  / *Case1 (no AB) -> basic misuse            label 1
  *Corrected*                     -> correct API use          label 0
  *ABICase*                       -> inter-procedural misuse  label 1
  *ABSCase*                       -> field-sensitive misuse   label 1
  *ABHCase*                       -> "false-positive test"    label 1, except the two
                                     cases the xlsx marks as secure (label 0)
Usage: ground_truth.py <bench_src_dir> <out.csv>
"""
import csv, pathlib, re, sys

PAPER_RULE = {  # folder -> rule number in the paper's Table 1
    "predictablecryptographickey": 1, "predictablepbepassword": 2,
    "predictablekeystorepassword": 3, "dummyhostnameverifier": 4,
    "dummycertvalidation": 5, "impropersslsocketfactory": 6, "http": 7,
    "predictableseeds": 8, "untrustedprng": 9, "staticsalts": 10, "ecbcrypto": 11,
    "staticinitializationvector": 12, "pbeiteration": 13, "brokencrypto": 14,
    "insecureasymmetriccrypto": 15, "brokenhash": 16,
}
SECURE_FP_TESTS = {"PredictablePBEPasswordABHCase1", "PredictableKeyStorePasswordABHCase1"}
SHARED_RULES = {1, 2, 3, 11, 14, 16}  # rules covered by all tools in paper Table 3


def category(stem):
    if "Corrected" in stem: return "correct"
    if "ABICase" in stem: return "interprocedural"
    if "ABSCase" in stem: return "field_sensitive"
    if "ABHCase" in stem: return "fp_test"
    return "basic"


def main(src, out):
    rows = []
    for f in sorted(pathlib.Path(src).rglob("*.java")):
        stem, folder = f.stem, f.parent.name
        cat = category(stem)
        label = 0 if (cat == "correct" or stem in SECURE_FP_TESTS) else 1
        rows.append(dict(case=stem, file=f.name, folder=folder, paper_rule=PAPER_RULE[folder],
                         category=cat, label=label,
                         shared_rule=int(PAPER_RULE[folder] in SHARED_RULES)))
    with open(out, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0]))
        w.writeheader(); w.writerows(rows)
    pos = sum(r["label"] for r in rows)
    print(f"{len(rows)} cases, {pos} positive, {len(rows)-pos} negative -> {out}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
