#!/usr/bin/env bash
# One-time environment setup (Ubuntu 22.04/24.04). Installs Java 8 + 21, the Java
# libraries CryptoGuard needs, and fetches the pinned tool/benchmark revisions into ext/.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/harness/pins.env"

if command -v apt-get >/dev/null; then
  SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
  $SUDO apt-get update -q
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends \
    openjdk-8-jdk-headless openjdk-21-jdk-headless git curl unzip python3 \
    libcommons-cli-java libcommons-lang3-java libcommons-io-java liblog4j2-java \
    libjackson2-core-java libjackson2-databind-java libjackson2-annotations-java \
    libjackson2-dataformat-xml-java libjackson2-dataformat-yaml groovy
fi

mkdir -p "$ROOT/ext"
cd "$ROOT/ext"
[ -d cryptoguard ] || git clone -q "$CG_REPO" cryptoguard
[ -d cryptoapi-bench ] || git clone -q "$BENCH_REPO" cryptoapi-bench
git -C cryptoguard fetch -q --all || true
git -C cryptoapi-bench fetch -q --all || true

# Tool binaries (GitHub release assets), verified by sha256.
mkdir -p "$ROOT/ext/tools"; cd "$ROOT/ext/tools"
if [ ! -f findsecbugs-cli.zip ]; then
  curl -sSL -o findsecbugs-cli.zip "$FSB_URL"
fi
echo "$FSB_SHA256  findsecbugs-cli.zip" | sha256sum -c -
rm -rf fsb && mkdir fsb && (cd fsb && unzip -q ../findsecbugs-cli.zip)
echo "setup OK"
