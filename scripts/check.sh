#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m py_compile "$ROOT/scripts/paperless_ai_recheck.py"

for file in \
    "$ROOT/scripts/paperless-ai-worker.sh" \
    "$ROOT/scripts/paperless-ai-post-consume.sh" \
    "$ROOT/scripts/paperless-ai-batch-parallel.sh" \
    "$ROOT/install.sh" \
    "$ROOT/uninstall.sh"
do
    bash -n "$file"
done

echo "Syntaxprüfung erfolgreich."
