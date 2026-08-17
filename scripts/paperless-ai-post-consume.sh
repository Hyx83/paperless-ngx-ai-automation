#!/usr/bin/env bash
set -Eeuo pipefail
umask 027

WORKER="/opt/paperless_data/scripts/paperless-ai-worker.sh"

if [[ ! "${DOCUMENT_ID:-}" =~ ^[1-9][0-9]*$ ]]; then
    echo "FEHLER: DOCUMENT_ID fehlt oder ist ungültig." >&2
    exit 2
fi

if [[ ! -x "$WORKER" ]]; then
    echo "FEHLER: KI-Worker fehlt oder ist nicht ausführbar: $WORKER" >&2
    exit 3
fi

APPLY_VALUE="${AI_POST_CONSUME_APPLY:-0}"
UNIT="paperless-ai-${DOCUMENT_ID}-$(date +%s%N)"

# Paperless wartet nicht auf die KI.
# Der Hintergrund-Worker begrenzt die globale KI-Parallelität auf drei Slots.
systemd-run \
    --quiet \
    --collect \
    --unit="$UNIT" \
    "$WORKER" "$DOCUMENT_ID" "$APPLY_VALUE" "post-consume"

exit 0
