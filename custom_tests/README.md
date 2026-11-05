# Custom test suite (bounded contribution)

- Put each test in `src/custom/<group>/<Name>.java` (package `custom.<group>`). One file = one test case.
- Add one row per file to `ground_truth_custom.csv`:
  `case,file,folder,paper_rule,category,label,shared_rule` — `paper_rule` uses the paper's Table 1 numbering (1–16),
  `label` is 1 for a misuse and 0 for a secure use, `shared_rule` is 1 if the rule is one of {1,2,3,11,14,16}.
- Put the prediction (expected TP/FN/FP/TN for CryptoGuard and why) in the file's Javadoc **before** running.
- `bash harness/build.sh && bash harness/run_all.sh <run_id>` picks the files up automatically;
  results land in `runs/<run_id>/custom_<tool>/scored/`.

`src/custom/pilot/` holds the 3 pilot probes used to validate the pipeline (see `docs/contribution_plan.md`).
