#!/usr/bin/env bash
set -Eeuo pipefail
umask 027

SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="/opt/paperless_data/scripts"

if [[ $EUID -ne 0 ]]; then
    echo "Dieses Installationsskript muss als root ausgeführt werden." >&2
    exit 1
fi

install -d -m 0750 "$TARGET"

install -m 0640 "$SOURCE_DIR/scripts/paperless_ai_recheck.py" \
    "$TARGET/paperless_ai_recheck.py"

install -m 0750 "$SOURCE_DIR/scripts/paperless-ai-worker.sh" \
    "$TARGET/paperless-ai-worker.sh"

install -m 0750 "$SOURCE_DIR/scripts/paperless-ai-post-consume.sh" \
    "$TARGET/paperless-ai-post-consume.sh"

install -m 0750 "$SOURCE_DIR/scripts/paperless-ai-batch-parallel.sh" \
    "$TARGET/paperless-ai-batch-parallel.sh"

if [[ ! -e "$TARGET/paperless-ai-mail.conf" ]]; then
    install -m 0600 "$SOURCE_DIR/config/paperless-ai-mail.conf.example" \
        "$TARGET/paperless-ai-mail.conf.example"
fi

echo
echo "Dateien installiert unter:"
echo "  $TARGET"
echo
echo "Die Paperless-Konfiguration wurde aus Sicherheitsgründen NICHT automatisch verändert."
echo
echo "Ergänze in /opt/paperless/paperless.conf zunächst:"
echo "  PAPERLESS_POST_CONSUME_SCRIPT=$TARGET/paperless-ai-post-consume.sh"
echo "  AI_POST_CONSUME_APPLY=0"
echo
echo "Danach:"
echo "  systemctl restart paperless-task-queue paperless-consumer"
echo
echo "Dry-Run:"
echo "  DOCUMENT_ID=<ID> AI_POST_CONSUME_APPLY=0 $TARGET/paperless-ai-post-consume.sh"
