#!/usr/bin/env bash
set -Eeuo pipefail
umask 027

AI_SCRIPT="/opt/paperless_data/scripts/paperless_ai_recheck.py"
MAIL_CONFIG="/opt/paperless_data/scripts/paperless-ai-mail.conf"

LOG1="/root/paperless-ai-parallel-worker1.log"
LOG2="/root/paperless-ai-parallel-worker2.log"
LOG3="/root/paperless-ai-parallel-worker3.log"

APPLY_VALUE="${APPLY:-0}"

exec 7>/run/paperless-ai-batch.lock
if ! flock -n 7; then
    echo "Es läuft bereits ein paralleler Paperless-AI-Batch."
    exit 4
fi

if [[ -r "$MAIL_CONFIG" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$MAIL_CONFIG"
    set +a
fi

cd /opt/paperless/src

RAW_IDS="$(
    uv run -- python manage.py shell -c \
    'from documents.models import Document; print(",".join(str(x) for x in Document.objects.order_by("id").values_list("id", flat=True)))'
)"

IDS_LINE="$(
    printf '%s\n' "$RAW_IDS" |
    grep -E '^[0-9]+(,[0-9]+)*$' |
    tail -n 1
)"

if [[ -z "$IDS_LINE" ]]; then
    echo "Keine Dokument-IDs ermittelt."
    exit 5
fi

IFS=',' read -r -a IDS <<< "$IDS_LINE"

IDS1=()
IDS2=()
IDS3=()

for i in "${!IDS[@]}"; do
    case $((i % 3)) in
        0) IDS1+=("${IDS[$i]}") ;;
        1) IDS2+=("${IDS[$i]}") ;;
        2) IDS3+=("${IDS[$i]}") ;;
    esac
done

JOIN1="$(IFS=,; echo "${IDS1[*]}")"
JOIN2="$(IFS=,; echo "${IDS2[*]}")"
JOIN3="$(IFS=,; echo "${IDS3[*]}")"

echo "Dokumente gesamt: ${#IDS[@]}"
echo "Worker 1: ${#IDS1[@]}"
echo "Worker 2: ${#IDS2[@]}"
echo "Worker 3: ${#IDS3[@]}"
echo "APPLY=${APPLY_VALUE}"
echo "Logs:"
echo "  $LOG1"
echo "  $LOG2"
echo "  $LOG3"

run_worker() {
    local slot="$1"
    local ids="$2"
    local log="$3"
    local fd=$((20 + slot))

    if [[ -z "$ids" ]]; then
        return 0
    fi

    eval "exec ${fd}>/run/paperless-ai-slot-${slot}.lock"
    flock -x "$fd"

    cd /opt/paperless/src

    DOCUMENT_IDS="$ids" \
    APPLY="$APPLY_VALUE" \
    DELAY_SECONDS=0 \
    uv run -- python manage.py shell < "$AI_SCRIPT" > "$log" 2>&1
}

run_worker 1 "$JOIN1" "$LOG1" &
PID1=$!

run_worker 2 "$JOIN2" "$LOG2" &
PID2=$!

run_worker 3 "$JOIN3" "$LOG3" &
PID3=$!

STATUS1=0
STATUS2=0
STATUS3=0

wait "$PID1" || STATUS1=$?
wait "$PID2" || STATUS2=$?
wait "$PID3" || STATUS3=$?

echo
echo "Worker 1 Exit-Code: $STATUS1"
echo "Worker 2 Exit-Code: $STATUS2"
echo "Worker 3 Exit-Code: $STATUS3"

if (( STATUS1 != 0 || STATUS2 != 0 || STATUS3 != 0 )); then
    exit 10
fi

echo "Paralleler Batch vollständig beendet."
