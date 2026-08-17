# Betrieb und Nutzung

## Einzelnes Dokument im Dry-Run

```bash
cd /opt/paperless/src
DOCUMENT_IDS=23 APPLY=0 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

## Einzelnes Dokument wirklich ändern

```bash
cd /opt/paperless/src
DOCUMENT_IDS=23 APPLY=1 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

## Mehrere Dokumente

```bash
cd /opt/paperless/src
DOCUMENT_IDS=23,26,41,48,53,67 APPLY=0 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

## Alle Dokumente

Ohne `DOCUMENT_IDS` verarbeitet das Skript den vollständigen gewählten Bestand:

```bash
cd /opt/paperless/src
APPLY=0 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

Vor einem vollständigen `APPLY=1`-Lauf sollte immer mindestens ein Dry-Run erfolgen.

## Anzahl begrenzen

```bash
cd /opt/paperless/src
LIMIT=10 APPLY=0 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

## Post-Consume manuell simulieren

```bash
DOCUMENT_ID=23 AI_POST_CONSUME_APPLY=0 /opt/paperless_data/scripts/paperless-ai-post-consume.sh
```

## Log

```bash
tail -f /opt/paperless_data/data/log/paperless-ai-post-consume.log
```

## Aktive Jobs

```bash
systemctl list-units --type=service 'paperless-ai-*'
```

## Konfliktdateien

```bash
ls -lh /root/paperless-ai-conflicts-*.csv
```

## Version prüfen

```bash
grep -n '^# Version:' /opt/paperless_data/scripts/paperless_ai_recheck.py | head -1
```

## Paperless-Dienststatus

```bash
systemctl status paperless-task-queue paperless-consumer --no-pager -l
```

## Live-Logs von Paperless

```bash
journalctl -u paperless-task-queue -u paperless-consumer -f
```
