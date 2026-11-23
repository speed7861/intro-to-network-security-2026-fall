#!/usr/bin/env bash
# Root-cause probes: small variants of the cases CryptoGuard misses, each compiled into its own
# jar and run through CG-2019, CG-2019 with refinement off, and CG-2020.
# Usage: harness/probes.sh <run_id>   -> runs/<run_id>/probes/PROBES.md (+ raw outputs)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/harness/pins.env"
P="$ROOT/runs/$1/probes"; rm -rf "$P"; mkdir -p "$P/.nodeps"
B="$ROOT/build"; export JAVA_HOME="$JDK8" JAVA7_HOME="$JDK8"

for f in $(find "$ROOT/probes" -name '*.java' | sort); do
  group=$(basename "$(dirname "$f")"); name=$(basename "$f" .java)
  t=$(mktemp -d); "$JDK8/bin/javac" -nowarn -g -encoding UTF-8 -d "$t" "$f" 2>/dev/null
  (cd "$t" && "$JDK8/bin/jar" cf "$P/$name.jar" .); rm -rf "$t"
  "$JDK8/bin/java" -cp "$(cat "$B/cg2019/classpath.txt")" main.rule.engine.RuleEngine \
    jar "$P/$name.jar" "$P/.nodeps" > "$P/$name.cg2019.txt" 2>/dev/null
  "$JDK8/bin/java" -Dcg.norefine=true -cp "$(cat "$B/cg2019nr/classpath.txt")" main.rule.engine.RuleEngine \
    jar "$P/$name.jar" "$P/.nodeps" > "$P/$name.cg2019nr.txt" 2>/dev/null
  "$JDK21/bin/java" -cp "$(cat "$B/cg2020/classpath.txt")" frontEnd.Interface.EntryPoint \
    -in jar -s "$P/$name.jar" -java "$JDK8" -m D -o "$P/$name.cg2020.json" -n >/dev/null 2>&1
  echo -e "$group\t$name" >> "$P/index.tsv"
done

python3 - "$P" <<'EOF'
import json, re, sys, pathlib
P = pathlib.Path(sys.argv[1])
# CryptoGuard rule ids: 3 = constant key (paper rule 1), 5 = small asymmetric key (paper rule 15)
TARGET = {"key": "3", "rsa": "5"}
def cg19(path, rule):
    hits = re.findall(r"\*\*\*Violated Rule " + rule + r": [^\n]*?\*\*\*Constants: (\[[^\]]*\])", path.read_text())
    return "detected " + ", ".join(hits) if hits else "missed"
def cg20(path, rule):
    try:
        iss = [i["Message"] for i in json.loads(path.read_text())["Issues"] if str(i["RuleNumber"]) == rule]
    except Exception as e:
        return f"error ({e.__class__.__name__})"
    return "detected " + "; ".join(iss) if iss else "missed"
rows = [l.split("\t") for l in (P / "index.tsv").read_text().split("\n") if l]
md = ["# Root-cause probes", "",
      "Each probe is compiled on its own and run through each tool. Only alerts for the probe's own rule are shown",
      "(constant key for `key/`, small RSA key for `rsa/`). Sources are in `probes/`.", "",
      "| Probe | CG-2019 | CG-2019, refinement off | CG-2020 |", "|---|---|---|---|"]
for g, n in rows:
    r = TARGET[g]
    md.append(f"| `{g}/{n}` | {cg19(P / (n + '.cg2019.txt'), r)} | {cg19(P / (n + '.cg2019nr.txt'), r)} | {cg20(P / (n + '.cg2020.json'), r)} |")
(P / "PROBES.md").write_text("\n".join(md) + "\n")
print("\n".join(md))
EOF
(cd "$P" && rm -rf .nodeps && find . -type f ! -name SHA256SUMS | sort | xargs sha256sum > SHA256SUMS)
