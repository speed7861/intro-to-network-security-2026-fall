#!/usr/bin/env python3
"""Score a tool's raw output against case-level ground truth.

Usage: score.py <cg2019|cg2020|fsb> <raw_output> <ground_truth.csv> <class_to_source.tsv> <out_dir>

Scoring unit = (test case, the paper rule that case targets). A case counts as detected if
the tool raises at least one alert that (a) maps to the case's paper rule and (b) is located
in a class compiled from the case's source file. Alerts for *other* rules are recorded in
alerts.csv as off-target and not counted (same convention as the paper's per-rule tables).

Writes: alerts.csv, per_case.csv, summary.json, summary.md
"""
import csv, json, re, sys, collections, xml.etree.ElementTree as ET
from pathlib import Path

# CryptoGuard's internal rule ids -> paper Table 1 rule numbers
CG_RULE_MAP = {1: {11, 14}, 2: {16}, 3: {1, 2}, 4: {5}, 5: {15}, 6: {4}, 7: {7}, 8: {13},
               9: {10}, 10: {12}, 11: {8}, 12: {6}, 13: {9}, 14: {3}}
# FindSecBugs bug types -> paper rules (types not listed are off-target, e.g. CIPHER_INTEGRITY)
FSB_RULE_MAP = {
    "HARD_CODE_KEY": {1}, "HARD_CODE_PASSWORD": {1, 2, 3}, "WEAK_HOSTNAME_VERIFIER": {4},
    "WEAK_TRUST_MANAGER": {5}, "UNENCRYPTED_SOCKET": {7}, "INSECURE_HTTP": {7},
    "PREDICTABLE_RANDOM": {9}, "ECB_MODE": {11}, "STATIC_IV": {12}, "DES_USAGE": {14},
    "TDES_USAGE": {14}, "BLOWFISH_KEY_SIZE": {14}, "RSA_KEY_SIZE": {15},
    "RSA_NO_PADDING": {15}, "WEAK_MESSAGE_DIGEST_MD5": {16}, "WEAK_MESSAGE_DIGEST_SHA1": {16},
    "HAZELCAST_SYMMETRIC_ENCRYPTION": {14},
}
# Paper Table 7 (all 16 rules, 112 cases): rule -> (GTP, CryptoGuard TP, CG FP, SpotBugs TP, SB FP)
PAPER_T7 = {1: (5, 5, 0, 2, 0), 2: (6, 6, 0, 3, 0), 3: (5, 5, 0, 2, 0), 4: (1, 1, 0, 1, 0),
            5: (1, 1, 0, 1, 0), 6: (4, 4, 0, None, None), 7: (4, 4, 0, None, None),
            8: (10, 5, 0, None, None), 9: (1, 1, 0, 1, 0), 10: (5, 3, 0, None, None),
            11: (4, 4, 0, 1, 1), 12: (6, 4, 0, 6, 0), 13: (5, 4, 0, None, None),
            14: (20, 20, 0, 5, 5), 15: (3, 2, 0, 0, 1), 16: (16, 16, 0, 4, 4)}
BENCH_CLASS = re.compile(r"(org\.cryptoapi\.bench\.[A-Za-z0-9_.$]+|custom\.[A-Za-z0-9_.$]+)")


def parse_cg2019(path):
    """Text report: blocks between '====' lines. 'Rule Na' blocks hold the constants that the
    refinement insights moved to the 'other sources' bucket (= alerts removed by refinement)."""
    alerts, text = [], Path(path).read_text(errors="replace")
    for block in re.split(r"\n=+\n", text):
        m = re.search(r"\*\*\*Violated Rule (\d+)(a?):", block)
        if not m:
            continue
        rule, group = int(m.group(1)), ("refined_out" if m.group(2) else "main")
        entries = re.findall(r"UnitContainer\{unit=(.*?), method='<([^:>]+):", block)
        if entries:
            for unit, cls in entries:
                alerts.append(dict(tool_rule=rule, group=group, cls=cls, detail=unit[:120]))
        else:
            classes = sorted({c.rstrip(".:") for c in BENCH_CLASS.findall(block)})
            for c in classes or [None]:
                alerts.append(dict(tool_rule=rule, group=group, cls=c,
                                   detail=block.strip().splitlines()[0][:120]))
    for a in alerts:
        a["paper_rules"] = CG_RULE_MAP.get(a["tool_rule"], set())
    return alerts


def parse_cg2020(path):
    d = json.loads(Path(path).read_text())
    out = []
    for i in d.get("Issues", []):
        fp = i.get("_FullPath", "")
        cls = fp.split(".jar/", 1)[-1].replace(".class", "").replace("/", ".") if fp else None
        r = int(i["RuleNumber"])
        out.append(dict(tool_rule=r, group="main", cls=cls, detail=i.get("Message", "")[:120],
                        paper_rules=CG_RULE_MAP.get(r, set())))
    return out


def parse_fsb(path):
    root = ET.parse(path).getroot()
    out = []
    for b in root.iter("BugInstance"):
        c = b.find("Class")
        t = b.get("type")
        out.append(dict(tool_rule=t, group="main", cls=c.get("classname") if c is not None else None,
                        detail=(b.findtext("ShortMessage") or "")[:120],
                        paper_rules=FSB_RULE_MAP.get(t, set())))
    return out


def prf(tp, fp, fn):
    p = tp / (tp + fp) if tp + fp else None
    r = tp / (tp + fn) if tp + fn else None
    return p, r


def fmt(x):
    return "—" if x is None else f"{100*x:.1f}%"


def main(tool, raw, gt_csv, cmap_tsv, out_dir):
    out = Path(out_dir); out.mkdir(parents=True, exist_ok=True)
    gt = list(csv.DictReader(open(gt_csv)))
    for g in gt:
        g["label"], g["paper_rule"] = int(g["label"]), int(g["paper_rule"])
    cls2case = {}
    for line in open(cmap_tsv):
        cls, src = line.rstrip("\n").split("\t")
        cls2case[cls] = src[:-5]
    alerts = {"cg2019": parse_cg2019, "cg2020": parse_cg2020, "fsb": parse_fsb}[tool](raw)

    case_rule = {g["case"]: g["paper_rule"] for g in gt}
    for a in alerts:
        a["case"] = cls2case.get(a["cls"]) if a["cls"] else None
        a["on_target"] = int(a["case"] is not None and case_rule.get(a["case"]) in a["paper_rules"])

    hit = collections.defaultdict(lambda: {"main": 0, "refined_out": 0})
    for a in alerts:
        if a["on_target"]:
            hit[a["case"]][a["group"]] += 1

    rows = []
    for g in gt:
        h = hit.get(g["case"], {"main": 0, "refined_out": 0})
        det = int(h["main"] > 0)
        det_noref = int(h["main"] + h["refined_out"] > 0)
        outcome = {(1, 1): "TP", (1, 0): "FN", (0, 1): "FP", (0, 0): "TN"}[(g["label"], det)]
        rows.append({**g, "detected": det, "outcome": outcome, "n_alerts": h["main"],
                     "n_refined_out": h["refined_out"], "detected_without_refinement": det_noref})

    def agg(sel, key="detected"):
        tp = sum(1 for r in sel if r["label"] and r[key]); fn = sum(1 for r in sel if r["label"] and not r[key])
        fp = sum(1 for r in sel if not r["label"] and r[key]); tn = sum(1 for r in sel if not r["label"] and not r[key])
        p, rc = prf(tp, fp, fn)
        return dict(n=len(sel), GTP=tp + fn, TP=tp, FP=fp, FN=fn, TN=tn, precision=p, recall=rc)

    S = {"tool": tool, "raw": str(raw), "overall": agg(rows),
         "by_category": {c: agg([r for r in rows if r["category"] == c])
                         for c in ["basic", "correct", "interprocedural", "field_sensitive", "fp_test"]},
         "by_rule": {str(k): agg([r for r in rows if r["paper_rule"] == k]) for k in range(1, 17)},
         "table3_shared_rules": {
             "basic": agg([r for r in rows if r["shared_rule"] == "1" and r["category"] in ("basic", "correct")]),
             "advanced": agg([r for r in rows if r["shared_rule"] == "1" and r["category"] not in ("basic", "correct")])},
         "alerts_total": len(alerts),
         "alerts_on_target": sum(a["on_target"] for a in alerts if a["group"] == "main"),
         "alerts_unattributed": sum(1 for a in alerts if a["case"] is None),
         }
    if tool == "cg2019":
        main_n = sum(1 for a in alerts if a["group"] == "main")
        ref_n = sum(1 for a in alerts if a["group"] == "refined_out")
        S["ablation_partial"] = {
            "alerts_kept": main_n, "alerts_refined_out": ref_n,
            "reduction": ref_n / (main_n + ref_n) if main_n + ref_n else None,
            "case_level_without_refinement": agg(rows, "detected_without_refinement")}

    with open(out / "per_case.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
    with open(out / "alerts.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["tool_rule", "group", "cls", "case", "paper_rules", "on_target", "detail"])
        w.writeheader()
        for a in alerts:
            w.writerow({**{k: a[k] for k in w.fieldnames if k != "paper_rules"},
                        "paper_rules": ";".join(map(str, sorted(a["paper_rules"])))})
    json.dump(S, open(out / "summary.json", "w"), indent=2, default=str)

    o = S["overall"]
    md = [f"# Scored run: `{tool}`", "",
          f"Cases: {o['n']} ({o['GTP']} positive / {o['n']-o['GTP']} negative). "
          f"Alerts: {S['alerts_total']} total, {S['alerts_on_target']} on-target, "
          f"{S['alerts_unattributed']} not attributable to a test file.", "",
          "| Slice | GTP | TP | FP | FN | TN | Precision | Recall |", "|---|---|---|---|---|---|---|---|"]
    def line(name, a):
        return f"| {name} | {a['GTP']} | {a['TP']} | {a['FP']} | {a['FN']} | {a['TN']} | {fmt(a['precision'])} | {fmt(a['recall'])} |"
    md.append(line(f"**All {o['n']} cases**", o))
    for c, a in S["by_category"].items():
        md.append(line(c, a))
    md += ["", "## Paper Table 3 analogue (6 shared rules: 1, 2, 3, 11, 14, 16)", "",
           "| Slice | GTP | TP | FP | FN | TN | Precision | Recall |", "|---|---|---|---|---|---|---|---|",
           line("basic (+correct)", S["table3_shared_rules"]["basic"]),
           line("advanced", S["table3_shared_rules"]["advanced"]), "",
           "## Per rule vs. paper Table 7", "",
           "| Rule | GTP (ours/paper) | TP ours | TP paper CG | TP paper SpotBugs | FP ours | FN ours |",
           "|---|---|---|---|---|---|---|"]
    for k in range(1, 17):
        a = S["by_rule"][str(k)]; p = PAPER_T7[k]
        md.append(f"| {k} | {a['GTP']}/{p[0]} | {a['TP']} | {p[1]} | {'—' if p[3] is None else p[3]} | {a['FP']} | {a['FN']} |")
    if "ablation_partial" in S:
        ab = S["ablation_partial"]; c = ab["case_level_without_refinement"]
        md += ["", "## Refinement ablation (partial — see docs/protocol.md §E2)", "",
               f"Alerts kept: {ab['alerts_kept']}; alerts moved to 'other sources' by refinement: "
               f"{ab['alerts_refined_out']} ({fmt(ab['reduction'])} reduction; paper reports 76–80% on real projects).", "",
               "Case-level if refined-out alerts were reported: " + line("no-refinement", c)]
    md += ["", "## Misses and false alarms", ""]
    for r in rows:
        if r["outcome"] in ("FN", "FP"):
            md.append(f"- **{r['outcome']}** `{r['case']}` (rule {r['paper_rule']}, {r['category']})"
                      + (f" — would be detected without refinement" if r["outcome"] == "FN" and r["detected_without_refinement"] else ""))
    (out / "summary.md").write_text("\n".join(md) + "\n")
    print(f"{tool}: P={fmt(o['precision'])} R={fmt(o['recall'])} TP={o['TP']} FP={o['FP']} FN={o['FN']} -> {out}/summary.md")


if __name__ == "__main__":
    main(*sys.argv[1:6])
