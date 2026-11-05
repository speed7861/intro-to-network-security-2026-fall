# Custom test suite

This folder holds our own test files (the bounded contribution).

How to add a test:

1. Put the file in `src/custom/<group>/<Name>.java`, using the package `custom.<group>`. One file is one test case.
2. In the file's Javadoc comment, write what you expect CryptoGuard to do (detect it, miss it, false alarm, or no alert) and why. Do this before running the tools.
3. Add a row to `ground_truth_custom.csv` with the columns `case,file,folder,paper_rule,category,label,shared_rule`:
   - `paper_rule` is the rule number from Table 1 of the paper (1 to 16).
   - `label` is 1 if the file contains a misuse and 0 if it is secure.
   - `shared_rule` is 1 if the rule is one of 1, 2, 3, 11, 14 or 16, otherwise 0.
4. Run `bash harness/build.sh` and then `bash harness/run_all.sh <run_id>`. The new files are picked up automatically, and results go in `runs/<run_id>/custom_<tool>/scored/`.

`src/custom/pilot/` has the three pilot files we used to test the pipeline. See `docs/contribution_plan.md` for what they check and the results.
