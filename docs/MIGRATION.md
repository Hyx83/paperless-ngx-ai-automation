# Migration auf den aktuellen Stand

Diese Anleitung richtet sich an Installationen, die eine ältere Projektfassung verwenden.

## Allgemeine Empfehlung

Vor jeder Migration:

```bash
cp -a /opt/paperless_data/scripts \
  /root/paperless-ai-scripts-backup-$(date +%Y%m%d-%H%M%S)
```

Zusätzlich sollte ein aktuelles Paperless-Datenbankbackup vorhanden sein.

---

## Von v1 auf v2+

Wichtigste Änderung:

> Automatische Datumsänderungen deaktivieren.

Vor einer weiteren Nutzung sollte kontrolliert werden, ob ältere Läufe bereits unerwünschte Dokumentdaten geändert haben.

---

## Von v2 auf v3+

Wichtigste Änderungen:

- strengere Fuzzy-Schwelle
- vorhandene Korrespondenten vollständig schützen
- Mehrfachorganisationen blockieren
- Einwort-Titel konservativer behandeln

Nach Migration empfiehlt sich ein Dry-Run über bereits bekannte Grenzfälle.

---

## Von v3 auf v4.1+

Wichtigste Änderung:

- zweite KI-Prüfung für neue Korrespondenten

Damit steigen API-Aufrufe und Laufzeit, die fachliche Sicherheit verbessert sich jedoch deutlich.

---

## Von v4.1 auf v4.2+

Keine Konfigurationsänderung erforderlich.

Die Mehrdeutigkeitslogik wird verbessert.

---

## Von v4.2 auf v4.3+

Neue Architektur:

- asynchroner Post-Consume-Hook
- separater KI-Worker
- parallele KI-Slots
- DB-Schreiblock

Erforderliche Dateien:

```text
paperless_ai_recheck.py
paperless-ai-worker.sh
paperless-ai-post-consume.sh
```

Paperless-Konfiguration:

```ini
PAPERLESS_POST_CONSUME_SCRIPT=/opt/paperless_data/scripts/paperless-ai-post-consume.sh
AI_POST_CONSUME_APPLY=0
```

Zuerst Dry-Run testen.

---

## Von v4.3 auf v4.4+

Keine zwingende Betriebsänderung.

Die CSV enthält danach nur noch manuell relevante Fälle.

Wer ein vollständiges Audit aller erfolgreichen Entscheidungen benötigt, muss dafür ein separates Logging ergänzen.

---

## Von v4.4 auf v4.5

Optional SMTP-Konfiguration ergänzen:

```text
/opt/paperless_data/scripts/paperless-ai-mail.conf
```

Dateirechte:

```bash
chmod 600 /opt/paperless_data/scripts/paperless-ai-mail.conf
```

Ohne diese Datei bzw. bei deaktiviertem Mailversand arbeitet v4.5 weiterhin ohne E-Mail-Berichte.

---

## Direktmigration auf v4.5

Für die meisten Installationen ist die einfachste Vorgehensweise:

```bash
./install.sh
```

Danach in:

```text
/opt/paperless/paperless.conf
```

zunächst:

```ini
PAPERLESS_POST_CONSUME_SCRIPT=/opt/paperless_data/scripts/paperless-ai-post-consume.sh
AI_POST_CONSUME_APPLY=0
```

Dienste neu laden:

```bash
systemctl restart paperless-task-queue paperless-consumer
```

Test:

```bash
DOCUMENT_ID=<TEST-ID> AI_POST_CONSUME_APPLY=0 \
/opt/paperless_data/scripts/paperless-ai-post-consume.sh
```

Erst danach:

```ini
AI_POST_CONSUME_APPLY=1
```
