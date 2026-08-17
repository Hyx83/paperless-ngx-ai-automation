#!/usr/bin/env bash
set -Eeuo pipefail
umask 027

DOCUMENT_ID_VALUE="${1:-}"
APPLY_VALUE="${2:-1}"
SOURCE_VALUE="${3:-post-consume}"

AI_SCRIPT="/opt/paperless_data/scripts/paperless_ai_recheck.py"
MAIL_CONFIG="/opt/paperless_data/scripts/paperless-ai-mail.conf"
LOG_DIR="/opt/paperless_data/data/log"
LOG_FILE="${LOG_DIR}/paperless-ai-post-consume.log"

if [[ ! "$DOCUMENT_ID_VALUE" =~ ^[1-9][0-9]*$ ]]; then
    echo "Ungültige Dokument-ID: ${DOCUMENT_ID_VALUE}" >&2
    exit 2
fi

mkdir -p "$LOG_DIR"

# Optionale SMTP-Konfiguration laden und an Python exportieren.
if [[ -r "$MAIL_CONFIG" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$MAIL_CONFIG"
    set +a
fi

# Maximal drei KI-Prozesse gleichzeitig.
while true; do
    for SLOT in 1 2 3; do
        FD=$((10 + SLOT))
        eval "exec ${FD}>/run/paperless-ai-slot-${SLOT}.lock"

        if flock -n "$FD"; then
            break 2
        fi

        eval "exec ${FD}>&-"
    done

    sleep 1
done

{
    echo
    echo "=============================================================================="
    echo "$(date '+%Y-%m-%d %H:%M:%S') Paperless AI Worker"
    echo "SOURCE=${SOURCE_VALUE}"
    echo "DOCUMENT_ID=${DOCUMENT_ID_VALUE}"
    echo "APPLY=${APPLY_VALUE}"
    echo "SLOT=${SLOT}"
    echo "=============================================================================="
} >> "$LOG_FILE"

cd /opt/paperless/src

DOCUMENT_IDS="$DOCUMENT_ID_VALUE" \
APPLY="$APPLY_VALUE" \
DELAY_SECONDS=0 \
uv run -- python manage.py shell < "$AI_SCRIPT" >> "$LOG_FILE" 2>&1

echo "$(date '+%Y-%m-%d %H:%M:%S') Dokument ${DOCUMENT_ID_VALUE} auf Slot ${SLOT} abgeschlossen." >> "$LOG_FILE"
