#!/usr/bin/env bash
# Usage: harness/run_tool.sh <cg2019|cg2020|fsb> <target.jar> <run_dir>
# Runs one tool on one jar and writes raw output + stderr + manifest.txt into <run_dir>.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/harness/pins.env"
TOOL="$1"; JAR="$(readlink -f "$2")"; OUT="$3"; mkdir -p "$OUT"
B="$ROOT/build"
export JAVA_HOME="$JDK8" JAVA7_HOME="$JDK8"
rc=0; start=$(date +%s.%N)
case "$TOOL" in
  cg2019)
    RAW="$OUT/cg2019_raw.txt"; mkdir -p "$OUT/.nodeps"
    CMD=("$JDK8/bin/java" -Xmx4g -cp "$(cat "$B/cg2019/classpath.txt")" main.rule.engine.RuleEngine jar "$JAR" "$OUT/.nodeps")
    "${CMD[@]}" > "$RAW" 2> "$OUT/cg2019_stderr.txt" || rc=$? ;;
  cg2020)
    RAW="$OUT/cg2020_raw.json"
    CMD=("$JDK21/bin/java" -Xmx4g -cp "$(cat "$B/cg2020/classpath.txt")" frontEnd.Interface.EntryPoint
         -in jar -s "$JAR" -java "$JDK8" -m D -o "$RAW" -n)
    "${CMD[@]}" > "$OUT/cg2020_stdout.txt" 2> "$OUT/cg2020_stderr.txt" || rc=$? ;;
  fsb)
    RAW="$OUT/fsb_raw.xml"; FSB="$ROOT/ext/tools/fsb"
    LIBS=$(ls "$FSB"/lib/*.jar | tr '\n' ':')
    CMD=("$JDK8/bin/java" -cp "$LIBS" edu.umd.cs.findbugs.LaunchAppropriateUI -quiet
         -pluginList "$FSB/lib/findsecbugs-plugin-1.12.0.jar" -include "$FSB/include.xml"
         -xml:withMessages -output "$RAW" "$JAR")
    "${CMD[@]}" > "$OUT/fsb_stdout.txt" 2> "$OUT/fsb_stderr.txt" || rc=$? ;;
  *) echo "unknown tool $TOOL"; exit 2 ;;
esac
end=$(date +%s.%N)
{
  echo "tool=$TOOL"
  echo "exit_code=$rc"
  echo "wall_seconds=$(python3 -c "print(round($end-$start,2))")"
  echo "date_utc=$(date -u +%FT%TZ)"
  echo "host=$(uname -srm)"
  echo "target_jar=$JAR"
  echo "target_sha256=$(sha256sum "$JAR" | cut -d' ' -f1)"
  echo "raw_output=$(basename "$RAW")"
  echo "raw_sha256=$(sha256sum "$RAW" | cut -d' ' -f1)"
  echo "cryptoguard_commit_cg2019=$CG2019_COMMIT cryptoguard_commit_cg2020=$CG2020_COMMIT bench112_commit=$BENCH112_COMMIT"
  echo "command=${CMD[*]}" | sed "s#$ROOT/##g"
} > "$OUT/${TOOL}_manifest.txt"
echo "[run] $TOOL rc=$rc -> $RAW"
