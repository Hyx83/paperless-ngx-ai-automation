#!/usr/bin/env bash
set -Eeuo pipefail

TARGET="/opt/paperless_data/scripts"

if [[ $EUID -ne 0 ]]; then
    echo "Dieses Skript muss als root ausgeführt werden." >&2
    exit 1
fi

echo "Entfernt werden nur die KI-Skripte. paperless.conf und Berichte bleiben erhalten."

rm -f \
    "$TARGET/paperless_ai_recheck.py" \
    "$TARGET/paperless-ai-worker.sh" \
    "$TARGET/paperless-ai-post-consume.sh" \
    "$TARGET/paperless-ai-batch-parallel.sh"

echo
echo "Entfernung abgeschlossen."
echo "Entferne PAPERLESS_POST_CONSUME_SCRIPT bei Bedarf manuell aus /opt/paperless/paperless.conf."
