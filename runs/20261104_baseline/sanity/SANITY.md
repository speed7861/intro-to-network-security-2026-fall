# Sanity checks

| Check | Result | Evidence |
|---|---|---|
| S1 ground truth matches paper (112 cases / 96 GTP / 16 secure, per-rule GTP) | PASS (totals) / PARTIAL per-rule: 14/16 rules equal, differ (ours,paper)={1: (6, 5), 3: (4, 5)} | cases=112 GTP=96 secure=16 |
| S2 negative controls (cg2019): 16 secure cases raise no alert for their rule | PASS | 16/16 clean; flagged=[] |
| S2 negative controls (cg2020): 16 secure cases raise no alert for their rule | PASS | 16/16 clean; flagged=[] |
| S2 negative controls (fsb): 16 secure cases raise no alert for their rule | PASS | 16/16 clean; flagged=[] |
| S3 positive control: BrokenHashBBCase2 (MD5) alone -> CG-2020 rule 'broken hash' alert | PASS | 1 issue(s): Found: "MD5" |
| S4 failure probe: PredictableCryptographicKeyBBCase1 (constant AES key, basic case) alone | REPRODUCED MISS (paper: detected) | CG-2020 issues=0, CG-2019 rule-3 alert=False |
| S5 determinism: CG-2020 run twice on all 112 cases -> identical issue multiset | PASS | run1=87 issues sha=5f798a8e0a325499, run2=87 issues sha=5f798a8e0a325499 |
| S6 CG-2019 per-rule TP equals paper Table 7 CryptoGuard column | 13/16 rules equal | differ (ours,paper): {1: (0, 5), 2: (4, 6), 3: (4, 5)} |
