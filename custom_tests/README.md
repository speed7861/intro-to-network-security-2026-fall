# Custom test suite

- `*.java` in this folder: Abdul's 15 test files (13 misuse patterns, 2 secure versions). The number at the end of each name is its test number.
- `spotbugs_custom_report.txt` and `spotbugs_custom_report.html`: Abdul's SpotBugs with FindSecBugs report on those files.
- `src/custom/pilot/`: the 3 pilot files we used to test the pipeline at the midpoint.
- `ground_truth_custom.csv`: the label for every file.

`bash harness/build.sh` compiles every `.java` file under this folder, and `bash harness/run_all.sh <run_id>` runs and scores them. Results go in `runs/<run_id>/custom_<tool>/scored/`. A summary is in `docs/results.md`, section 2.

## Labels

`ground_truth_custom.csv` has the columns `case,file,folder,paper_rule,category,label,shared_rule,extra_rules`:

- `paper_rule` is the rule number from Table 1 of the paper (1 to 16) that the file tests.
- `label` is 1 if the file contains a misuse and 0 if it is secure.
- `shared_rule` is 1 if the rule is one of 1, 2, 3, 11, 14 or 16 (the rules every tool in the paper covers), otherwise 0.
- `extra_rules` is optional, for secure files only. It lists more rules separated by `;`. An alert for any of them on that file also counts as a false alarm.

To add a test, put the file here, add a row to the CSV, and rebuild.
