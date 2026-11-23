#!/usr/bin/env bash
# Builds: (1) the 112-case benchmark jar, (2) the custom-test jar, (3) CryptoGuard CG-2019,
# (4) CryptoGuard CG-2020. Output goes to build/. Re-runnable; wipes build/ first.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/harness/pins.env"
B="$ROOT/build"; rm -rf "$B"; mkdir -p "$B"
J=/usr/share/java
log(){ echo "[build] $*"; }

# ---------- benchmark (paper version, 112 files), compiled with JDK 8 ----------
build_bench () {  # $1=commit $2=name
  local d="$B/$2"; mkdir -p "$d/classes"
  git -C "$ROOT/ext/cryptoapi-bench" archive "$1" src | tar -x -C "$d"
  "$JDK8/bin/javac" -nowarn -g -encoding UTF-8 -d "$d/classes" $(find "$d/src" -name '*.java') 2>&1 | grep -v "Picked up" || true
  (cd "$d/classes" && "$JDK8/bin/jar" cf "../$2.jar" .)
  # class -> source file map (used to attribute alerts to test cases)
  find "$d/classes" -name '*.class' | sort | xargs "$JDK8/bin/javap" -v 2>/dev/null \
    | awk '/^Classfile /{c=$2} /^SourceFile: /{gsub(/"/,"",$2); print c"\t"$2}' \
    | sed "s#$d/classes/##; s#\.class\t#\t#; s#/#.#g" > "$d/class_to_source.tsv"
  log "$2: $(find "$d/src" -name '*.java' | wc -l) java files, $(wc -l < "$d/class_to_source.tsv") classes"
}
build_bench "$BENCH112_COMMIT" bench112

# ---------- custom tests (team contribution; may be empty early on) ----------
mkdir -p "$B/custom/classes"
# Picks up every .java file under custom_tests/ (pilot files in src/custom/pilot, the suite files at the top level).
if [ -d "$ROOT/custom_tests" ] && find "$ROOT/custom_tests" -name '*.java' | grep -q .; then
  "$JDK8/bin/javac" -nowarn -g -encoding UTF-8 -d "$B/custom/classes" $(find "$ROOT/custom_tests" -name '*.java') 2>&1 | grep -v "Picked up" || true
  (cd "$B/custom/classes" && "$JDK8/bin/jar" cf ../custom.jar .)
  find "$B/custom/classes" -name '*.class' | sort | xargs "$JDK8/bin/javap" -v 2>/dev/null \
    | awk '/^Classfile /{c=$2} /^SourceFile: /{gsub(/"/,"",$2); print c"\t"$2}' \
    | sed "s#$B/custom/classes/##; s#\.class\t#\t#; s#/#.#g" > "$B/custom/class_to_source.tsv"
  log "custom: $(find "$ROOT/custom_tests" -name '*.java' | wc -l) java files"
fi

# ---------- CryptoGuard CG-2019 (ccs-submission branch), Java 8 ----------
d="$B/cg2019"; mkdir -p "$d/src" "$d/classes"
git -C "$ROOT/ext/cryptoguard" archive "$CG2019_COMMIT" main | tar -x -C "$d/src"
CP19="$d/src/main/libs/soot-trunk.jar:$d/src/main/libs/dexlib2-2.2.1.jar:$J/groovy-all.jar"
"$JDK8/bin/javac" -nowarn -encoding UTF-8 -d "$d/classes" -cp "$CP19" $(find "$d/src/main/src" -name '*.java') 2>&1 | grep -v "Picked up" || true
echo "$d/classes:$CP19" > "$d/classpath.txt"
log "cg2019: $(find "$d/classes" -name '*.class' | wc -l) classes"

# ---------- CG-2019 with a refinement switch (for the ablation, experiment E2) ----------
# Same source with harness/patch_norefine.py applied. Behaves like CG-2019 unless run with
# -Dcg.norefine=true (sanity check S7 confirms this).
d="$B/cg2019nr"; mkdir -p "$d/src" "$d/classes"
git -C "$ROOT/ext/cryptoguard" archive "$CG2019_COMMIT" main | tar -x -C "$d/src"
python3 "$ROOT/harness/patch_norefine.py" "$d/src" >/dev/null
CP19NR="$d/src/main/libs/soot-trunk.jar:$d/src/main/libs/dexlib2-2.2.1.jar:$J/groovy-all.jar"
"$JDK8/bin/javac" -nowarn -encoding UTF-8 -d "$d/classes" -cp "$CP19NR" $(find "$d/src/main/src" -name '*.java') 2>&1 | grep -v "Picked up" || true
echo "$d/classes:$CP19NR" > "$d/classpath.txt"
log "cg2019nr: $(find "$d/classes" -name '*.class' | wc -l) classes (refinement switch patched in)"

# ---------- CryptoGuard CG-2020 (v04.05.03) ----------
# Maven Central/Gradle 6 are not required: deps come from the Ubuntu Java packages
# (Jackson there is built for Java 17), so CG-2020 is compiled --release 17 and *run* on
# JDK 21, while Soot analyses the target against JDK 8's rt.jar/jce.jar (-java flag).
d="$B/cg2020"; mkdir -p "$d/src" "$d/classes" "$d/libs"
git -C "$ROOT/ext/cryptoguard" archive "$CG2020_COMMIT" src libs | tar -x -C "$d/src"
cp "$d/src/libs/"*.jar "$d/libs/"
# AXMLPrinter2.jar has a "/." zip entry that newer javac rejects -> repack (Android-only lib).
( t=$(mktemp -d); cd "$t"; unzip -o -q "$d/libs/AXMLPrinter2.jar" 2>/dev/null || true
  rm "$d/libs/AXMLPrinter2.jar"; "$JDK21/bin/jar" cf "$d/libs/AXMLPrinter2.jar" .; rm -rf "$t" )
CP20="$(ls "$d"/libs/*.jar | tr '\n' ':')$J/commons-cli.jar:$J/commons-lang3.jar:$J/commons-io.jar:$J/log4j-api.jar:$J/log4j-core.jar:$J/jackson-core.jar:$J/jackson-databind.jar:$J/jackson-annotations.jar:$J/jackson-dataformat-xml.jar:$J/jackson-dataformat-yaml.jar:$J/snakeyaml.jar:$J/stax2-api.jar:$J/groovy-all.jar"
"$JDK21/bin/javac" -nowarn -encoding UTF-8 --release 17 -d "$d/classes" -cp "$CP20" $(find "$d/src/src/main/java" -name '*.java') 2>&1 | grep -v "Picked up" || true
cp -r "$d/src/src/main/resources/"* "$d/classes/"
echo "$d/classes:$CP20" > "$d/classpath.txt"
log "cg2020: $(find "$d/classes" -name '*.class' | wc -l) classes"
log "done"
