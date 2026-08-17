# Installation

## Voraussetzungen

Die Dokumentation geht von folgender Struktur aus:

```text
/opt/paperless/
├── paperless.conf
└── src/

/opt/paperless_data/
├── data/
├── media/
├── consume/
└── scripts/
```

Benötigt werden außerdem:

- eine funktionierende Paperless-ngx-Installation
- das Python-Modul `paperless_ai`
- ein in Paperless konfiguriertes LLM
- `systemd`
- `systemd-run`
- `flock`
- Schreibzugriff auf `/run` für Lock-Dateien
- Zugriff des Paperless-Systems auf den konfigurierten LLM-Endpunkt

## Dateien

Empfohlene Struktur:

```text
/opt/paperless_data/scripts/
├── paperless_ai_recheck.py
├── paperless-ai-worker.sh
├── paperless-ai-post-consume.sh
└── paperless-ai-mail.conf
```

`paperless-ai-mail.conf` ist optional.

## Installation

```bash
mkdir -p /opt/paperless_data/scripts
```

```bash
./install.sh
```

Rechte:

```bash
chmod 640 /opt/paperless_data/scripts/paperless_ai_recheck.py
chmod 750 /opt/paperless_data/scripts/paperless-ai-worker.sh
chmod 750 /opt/paperless_data/scripts/paperless-ai-post-consume.sh
```

## Post-Consume aktivieren

In `/opt/paperless/paperless.conf`:

```ini
PAPERLESS_POST_CONSUME_SCRIPT=/opt/paperless_data/scripts/paperless-ai-post-consume.sh
AI_POST_CONSUME_APPLY=0
```

`AI_POST_CONSUME_APPLY=0` ist für den ersten Test absichtlich gewählt.

Anschließend:

```bash
systemctl restart paperless-task-queue paperless-consumer
```

## Funktionstest

### Wrapper direkt testen

```bash
time DOCUMENT_ID=23 AI_POST_CONSUME_APPLY=0 /opt/paperless_data/scripts/paperless-ai-post-consume.sh
```

Da der Hook nur einen Hintergrundjob startet, sollte er sehr schnell zurückkehren.

### Log beobachten

```bash
tail -f /opt/paperless_data/data/log/paperless-ai-post-consume.log
```

Erwartet:

```text
SOURCE=post-consume
DOCUMENT_ID=23
APPLY=0
SLOT=1
```

Das Python-Skript muss anschließend nur ein Dokument laden:

```text
Dokumente: 1
```

## Live-Betrieb aktivieren

Nach erfolgreichem Dry-Run:

```bash
sed -i 's/^AI_POST_CONSUME_APPLY=.*/AI_POST_CONSUME_APPLY=1/' /opt/paperless/paperless.conf
```

Danach:

```bash
systemctl restart paperless-task-queue paperless-consumer
```

## Rückbau

Post-Consume deaktivieren:

```bash
sed -i '/^PAPERLESS_POST_CONSUME_SCRIPT=/d' /opt/paperless/paperless.conf
```

Danach:

```bash
systemctl restart paperless-task-queue paperless-consumer
```

Die bereits gesetzten Paperless-Metadaten werden dadurch nicht zurückgesetzt.
