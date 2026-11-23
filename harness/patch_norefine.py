#!/usr/bin/env python3
"""Patch a copy of CG-2019 (ccs-submission) so its refinement insights can be switched off.

Usage: patch_norefine.py <cg2019 source root, i.e. the folder containing main/src>

With -Dcg.norefine=true, every constant that a refinement insight (RI-I..RI-V) would discard
is reported as a violation instead. With the property unset the patched build behaves exactly
like the original (checked by sanity check S7).

Only refinement drops are switched off. The rules' own checks stay in place: key size >= minSize
(rule 15), iteration count >= 1000 (rule 13), and the regex match for broken crypto/hash/HTTP.

Drop points, CryptoGuard rule ids (paper rule in brackets):
  PredictableSourceRuleChecker (CG rules 3, 14, 9, 10, 11 -> paper rules 1/2, 3, 10, 12, 8)
    - constant is null or ""                                   RI-V
    - int constant not assigned into a byte                     RI-III / RI-IV
    - constant is an argument of an invoke inside an assignment RI-I / RI-II
    - constant is an array size (newarray)                      RI-III
    - slice value flows into an orthogonal invoke               RI-I / RI-II / RI-IV
    - constant only reaches an interfaceinvoke as an identifier RI-II
  PBEInterationCountFinder (rule 8 -> paper 13): the same invoke/identifier drops
  ExportGradeKeyInitializationFinder (rule 5 -> paper 15): the same invoke/identifier drops,
    plus a small key size that appears directly as an argument of a non-assignment invoke
    statement such as kpg.initialize(512)                     RI-IV (context/type heuristic)
"""
import pathlib, sys

root = pathlib.Path(sys.argv[1]) / "main/src/main/java/main"
OTHERS = "putIntoMap(othersSourceMap,"
OFF = "putIntoMap(main.util.Refine.OFF ? predictableSourcMap : othersSourceMap,"

(root / "util/Refine.java").write_text(
    "package main.util;\n\n"
    "/** Switch for the refinement ablation: run with -Dcg.norefine=true to turn refinement off. */\n"
    "public final class Refine {\n"
    "    public static final boolean OFF = Boolean.getBoolean(\"cg.norefine\");\n"
    "    private Refine() {}\n"
    "}\n")


def patch(rel, edits):
    p = root / rel
    lines = p.read_text().split("\n")
    for lineno, expect, new in edits:
        cur = lines[lineno - 1]
        assert expect in cur, f"{rel}:{lineno}: expected {expect!r}, found {cur.strip()!r}"
        lines[lineno - 1] = cur.replace(expect, new) if new is not None else cur
    p.write_text("\n".join(lines))


# 1. PredictableSourceRuleChecker: every "others" put is a refinement drop.
p = root / "rule/base/PredictableSourceRuleChecker.java"
src = p.read_text()
n = src.count(OTHERS)
assert n == 6, f"expected 6 drop points in PredictableSourceRuleChecker, found {n}"
p.write_text(src.replace(OTHERS, OFF))

# 2. PBE iteration count: lines 120, 149, 174 are refinement drops; 183 is the >= 1000 check.
patch("rule/PBEInterationCountFinder.java", [
    (120, OTHERS, OFF), (149, OTHERS, OFF), (174, OTHERS, OFF), (183, OTHERS, None)])

# 3. RSA/EC key size: 128, 157, 185 are refinement drops; 194 is the size check.
#    197 drops any constant whose unit is not an assignment (e.g. kpg.initialize(512)); with
#    refinement off, a small even key size there is reported, using the rule's own size test.
SIZE_OFF = ("if (main.util.Refine.OFF && usebox.getValue().getType() instanceof IntegerType"
            " && Integer.valueOf(usebox.getValue().toString()) != 0"
            " && Integer.valueOf(usebox.getValue().toString()) % 2 == 0"
            " && Integer.valueOf(usebox.getValue().toString()) < minSize)"
            " { outSet.put(e, usebox.getValue().toString()); } else "
            "putIntoMap(othersSourceMap,")
patch("rule/ExportGradeKeyInitializationFinder.java", [
    (128, OTHERS, OFF), (157, OTHERS, OFF), (185, OTHERS, OFF), (194, OTHERS, None),
    (197, OTHERS, SIZE_OFF)])
print("patched", root)
