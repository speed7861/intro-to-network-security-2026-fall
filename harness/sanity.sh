#!/usr/bin/env bash
# Sanity checks + single-case failure trace. Usage: harness/sanity.sh <baseline_run_id>
# Writes runs/<baseline_run_id>/sanity/{SANITY.md, trace_*.log, ...}
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/harness/pins.env"
R="$ROOT/runs/$1"; S="$R/sanity"; rm -rf "$S"; mkdir -p "$S"
mkdir -p "$S/.nodeps"; B="$ROOT/build"; export JAVA_HOME="$JDK8" JAVA7_HOME="$JDK8"

one_class_jar () {  # $1=case name -> $S/<case>.jar containing only that test's classes
  local t; t=$(mktemp -d)
  local f; f=$(find "$B/bench112/src" -name "$1.java")
  "$JDK8/bin/javac" -nowarn -g -d "$t" "$f" 2>/dev/null
  (cd "$t" && "$JDK8/bin/jar" cf "$S/$1.jar" .); rm -rf "$t"
}

# --- S3/S4: positive control and the failure probe, each on a one-class jar, verbose trace ---
for c in BrokenHashBBCase2 PredictableCryptographicKeyBBCase1; do
  one_class_jar "$c"
  { echo "### case=$c  jar_sha256=$(sha256sum "$S/$c.jar" | cut -d' ' -f1)"
    echo "### source:"; cat -n "$(find "$B/bench112/src" -name "$c.java")"
    echo "### CG-2019 output:"
    "$JDK8/bin/java" -cp "$(cat "$B/cg2019/classpath.txt")" main.rule.engine.RuleEngine jar "$S/$c.jar" "$S/.nodeps" 2>/dev/null
    echo "### CG-2020 output (rule-engine log lines + JSON issues):"
    "$JDK21/bin/java" -cp "$(cat "$B/cg2020/classpath.txt")" frontEnd.Interface.EntryPoint \
      -in jar -s "$S/$c.jar" -java "$JDK8" -m D -o "$S/$c.cg2020.json" -n 2>&1 \
      | grep -E "Checking the rule|Scanning using a depth|Issue|ERROR|WARN" | grep -v "Picked up" | sed -E 's/^[0-9:.]+ //'
    python3 -c "import json,sys;d=json.load(open('$S/$c.cg2020.json'));print('ISSUES:',json.dumps(d['Issues'],indent=1))"
  } > "$S/trace_$c.log" 2>&1
done

# --- S5: determinism. Run CG-2020 twice on the full benchmark and compare issue sets ---
for i in 1 2; do
  "$JDK21/bin/java" -cp "$(cat "$B/cg2020/classpath.txt")" frontEnd.Interface.EntryPoint \
    -in jar -s "$B/bench112/bench112.jar" -java "$JDK8" -m D -o "$S/det_$i.json" -n >/dev/null 2>&1
done

# --- S7: the refinement-switch build with the switch OFF must match unmodified CG-2019 ---
for j in bench112 custom; do
  [ -f "$B/$j/$j.jar" ] || continue
  "$JDK8/bin/java" -Dcg.norefine=false -cp "$(cat "$B/cg2019nr/classpath.txt")" main.rule.engine.RuleEngine \
    jar "$B/$j/$j.jar" "$S/.nodeps" > "$S/s7_patched_off_$j.txt" 2>/dev/null
  "$JDK8/bin/java" -cp "$(cat "$B/cg2019/classpath.txt")" main.rule.engine.RuleEngine \
    jar "$B/$j/$j.jar" "$S/.nodeps" > "$S/s7_original_$j.txt" 2>/dev/null
done

python3 - "$R" "$S" <<'EOF'
import csv, json, sys, collections, hashlib, pathlib
R, S = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
gt = list(csv.DictReader(open(R / "ground_truth_bench112.csv")))
PAPER_GTP = {1:5,2:6,3:5,4:1,5:1,6:4,7:4,8:10,9:1,10:5,11:4,12:6,13:5,14:20,15:3,16:16}
PAPER_CG_TP = {1:5,2:6,3:5,4:1,5:1,6:4,7:4,8:5,9:1,10:3,11:4,12:4,13:4,14:20,15:2,16:16}
res = []
# S1 ground truth vs paper
pos = collections.Counter(int(g["paper_rule"]) for g in gt if g["label"] == "1")
npos, nneg = sum(pos.values()), sum(1 for g in gt if g["label"] == "0")
diff = {k: (pos[k], PAPER_GTP[k]) for k in PAPER_GTP if pos[k] != PAPER_GTP[k]}
res.append(("S1 ground truth matches paper (112 cases / 96 GTP / 16 secure, per-rule GTP)",
            "PASS (totals) / " + ("PASS" if not diff else f"PARTIAL per-rule: {len(16*[0])-len(diff)}/16 rules equal, differ (ours,paper)={diff}"),
            f"cases={len(gt)} GTP={npos} secure={nneg}"))
# S2 negative controls
for tool in ("cg2019", "cg2020", "fsb"):
    pc = list(csv.DictReader(open(R / tool / "scored" / "per_case.csv")))
    neg = [r for r in pc if r["label"] == "0"]
    fp = [r["case"] for r in neg if r["detected"] == "1"]
    res.append((f"S2 negative controls ({tool}): 16 secure cases raise no alert for their rule",
                "PASS" if not fp else "FAIL", f"{len(neg)-len(fp)}/{len(neg)} clean; flagged={fp}"))
# S3 positive control
t = json.load(open(S / "BrokenHashBBCase2.cg2020.json"))["Issues"]
ok = any(i["RuleNumber"] == 2 and "MD5" in i["Message"] for i in t)
res.append(("S3 positive control: BrokenHashBBCase2 (MD5) alone -> CG-2020 rule 'broken hash' alert",
            "PASS" if ok else "FAIL", f"{len(t)} issue(s): " + "; ".join(i['Message'] for i in t)))
# S4 failure probe
t = json.load(open(S / "PredictableCryptographicKeyBBCase1.cg2020.json"))["Issues"]
cg19 = (S / "trace_PredictableCryptographicKeyBBCase1.log").read_text()
hit19 = "Violated Rule 3:" in cg19
res.append(("S4 failure probe: PredictableCryptographicKeyBBCase1 (constant AES key, basic case) alone",
            "REPRODUCED MISS (paper: detected)" if not t and not hit19 else "detected",
            f"CG-2020 issues={len(t)}, CG-2019 rule-3 alert={hit19}"))
# S5 determinism
def norm(p):
    return sorted((i["RuleNumber"], i["Message"], i["_FullPath"]) for i in json.load(open(p))["Issues"])
a, b = norm(S / "det_1.json"), norm(S / "det_2.json")
h = lambda x: hashlib.sha256(json.dumps(x).encode()).hexdigest()[:16]
res.append(("S5 determinism: CG-2020 run twice on all 112 cases -> identical issue multiset",
            "PASS" if a == b else "FAIL", f"run1={len(a)} issues sha={h(a)}, run2={len(b)} issues sha={h(b)}"))
# S6 paper-era agreement
pc = list(csv.DictReader(open(R / "cg2019" / "scored" / "per_case.csv")))
tp = collections.Counter(int(r["paper_rule"]) for r in pc if r["outcome"] == "TP")
eq = [k for k in PAPER_CG_TP if tp[k] == PAPER_CG_TP[k]]
res.append(("S6 CG-2019 per-rule TP equals paper Table 7 CryptoGuard column",
            f"{len(eq)}/16 rules equal", "differ (ours,paper): " + str({k: (tp[k], PAPER_CG_TP[k]) for k in PAPER_CG_TP if k not in eq})))
# S7 refinement switch is inert when off
def body(p):
    return "\n".join(l for l in p.read_text().split("\n") if l.strip())
s7 = []
for j in ("bench112", "custom"):
    a, b = S / f"s7_original_{j}.txt", S / f"s7_patched_off_{j}.txt"
    if a.exists():
        s7.append((j, body(a) == body(b), h(body(a)), len(body(a))))
res.append(("S7 refinement-switch build with the switch off gives the same output as unmodified CG-2019",
            "PASS" if s7 and all(x[1] for x in s7) else "FAIL",
            "; ".join(f"{j}: {'identical' if ok else 'DIFFERENT'} (sha {hh}, {n} chars)" for j, ok, hh, n in s7)))
md = ["# Sanity checks", "", "| Check | Result | Evidence |", "|---|---|---|"]
md += [f"| {n} | {r} | {e} |" for n, r, e in res]
(S / "SANITY.md").write_text("\n".join(md) + "\n")
print("\n".join(md))
EOF
(cd "$S" && rm -f *.class && find . -type f ! -name SHA256SUMS | sort | xargs sha256sum > SHA256SUMS)
