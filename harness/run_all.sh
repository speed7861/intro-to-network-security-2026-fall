#!/usr/bin/env bash
# Full baseline: CG-2019, CG-2020 and FindSecBugs on the 112-case benchmark (+ custom tests
# if present), scored against ground truth. Usage: harness/run_all.sh [run_id]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/harness/pins.env"
RUN_ID="${1:-$(date -u +%Y%m%d-%H%M%S)_baseline}"
R="$ROOT/runs/$RUN_ID"; mkdir -p "$R"
B="$ROOT/build"

python3 "$ROOT/harness/ground_truth.py" "$B/bench112/src" "$ROOT/data/ground_truth_bench112.csv"
cp "$ROOT/data/ground_truth_bench112.csv" "$R/"

for tool in cg2019 cg2020 fsb; do
  "$ROOT/harness/run_tool.sh" "$tool" "$B/bench112/bench112.jar" "$R/$tool"
  case $tool in cg2019) raw=cg2019_raw.txt;; cg2020) raw=cg2020_raw.json;; fsb) raw=fsb_raw.xml;; esac
  python3 "$ROOT/harness/score.py" "$tool" "$R/$tool/$raw" "$ROOT/data/ground_truth_bench112.csv" \
    "$B/bench112/class_to_source.tsv" "$R/$tool/scored"
done

if [ -f "$B/custom/custom.jar" ] && [ -f "$ROOT/custom_tests/ground_truth_custom.csv" ]; then
  for tool in cg2019 cg2020 fsb; do
    "$ROOT/harness/run_tool.sh" "$tool" "$B/custom/custom.jar" "$R/custom_$tool"
    case $tool in cg2019) raw=cg2019_raw.txt;; cg2020) raw=cg2020_raw.json;; fsb) raw=fsb_raw.xml;; esac
    python3 "$ROOT/harness/score.py" "$tool" "$R/custom_$tool/$raw" "$ROOT/custom_tests/ground_truth_custom.csv" \
      "$B/custom/class_to_source.tsv" "$R/custom_$tool/scored"
  done
fi
(cd "$R" && find . -type f ! -name SHA256SUMS | sort | xargs sha256sum > SHA256SUMS)
echo "run complete: runs/$RUN_ID"
