# Konflikt-CSV und E-Mail-Bericht

## Ziel

Die CSV ist kein vollständiges Audit-Protokoll aller Dokumente.

Sie enthält bewusst nur Fälle, bei denen eine manuelle Prüfung sinnvoll ist.

## In der CSV landen

- mehrdeutige oder mehrere KI-Korrespondenten
- Konflikt zwischen vorhandenem Korrespondenten und KI-Vorschlag
- erste KI schlägt einen Korrespondenten vor, die zweite Prüfung verwirft ihn
- kein sicherer KI-Korrespondent, obwohl am Dokument keiner gesetzt ist
- technische Fehler

## Nicht in der CSV landen

- normale erfolgreiche Titeländerungen
- bestätigte vorhandene Korrespondenten
- erfolgreiche Neuanlagen
- reine Datumsabweichungen
- unveränderte Dokumente ohne Prüfbedarf

## Dateinamen

Einzelne Post-Consume-Jobs:

```text
paperless-ai-conflicts-YYYYMMDD-HHMMSS-doc-123.csv
```

Batch-Prozesse:

```text
paperless-ai-conflicts-YYYYMMDD-HHMMSS-pid-12345.csv
```

Damit überschreiben parallele Prozesse ihre Dateien nicht gegenseitig.

## Spalten

Die CSV enthält:

| Feld | Bedeutung |
|---|---|
| Dokument-ID | Paperless-ID |
| Status | Dry-Run, gespeichert, unverändert oder Fehler |
| Alter Titel | Ausgangswert |
| KI-Titel | KI-Vorschlag |
| Neuer Titel | finaler Wert |
| Titel-Aktion | Begründung |
| Alter Korrespondent | Ausgangswert |
| KI-Korrespondenten | Vorschläge |
| Neuer Korrespondent | finaler Wert |
| Korrespondent-Aktion | Entscheidung |
| Korrespondent-Verifikation | Ergebnis der zweiten Prüfung |
| Aktuelles Datum | Paperless-Datum |
| KI-Daten | erkannte Datumswerte |
| Datum-Aktion | bleibt unverändert |
| Alter Dateiname | Ausgangsdatei |
| Vorschau Dateiname | erwarteter Name |
| Tatsächlicher Dateiname | nach Speicherung |
| Fehler | technische Fehlermeldung |

Die CSV wird UTF-8-kompatibel und Excel-freundlich geschrieben.

## SMTP-Versand

Konfiguration:

```text
/opt/paperless_data/scripts/paperless-ai-mail.conf
```

Beispiel:

```bash
AI_REPORT_EMAIL_ENABLED=1
AI_REPORT_SMTP_HOST='smtp.example.de'
AI_REPORT_SMTP_PORT=587
AI_REPORT_SMTP_SECURITY='starttls'
AI_REPORT_SMTP_USER='paperless@example.de'
AI_REPORT_SMTP_PASSWORD='PASSWORT'
AI_REPORT_MAIL_FROM='paperless@example.de'
AI_REPORT_MAIL_TO='admin@example.de'
AI_REPORT_DELETE_EMPTY_CSV=1
```

Rechte:

```bash
chmod 600 /opt/paperless_data/scripts/paperless-ai-mail.conf
```

## Versandlogik

```text
kein Prüffall
→ keine E-Mail
→ leere CSV optional löschen

mindestens ein Prüffall
→ CSV behalten
→ E-Mail mit CSV-Anhang senden
```

Ein SMTP-Fehler wird nur als Warnung protokolliert. Er macht eine zuvor erfolgreiche Dokumentänderung nicht rückgängig.

## Test

Für einen gezielten Dry-Run:

```bash
cd /opt/paperless/src
DOCUMENT_IDS=23 APPLY=0 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

Falls dieser Test einen Konflikt erzeugt und die SMTP-Konfiguration geladen ist, wird der Bericht versendet.

Beim direkten Python-Aufruf muss die SMTP-Konfiguration entweder exportiert oder vorab geladen werden:

```bash
set -a
source /opt/paperless_data/scripts/paperless-ai-mail.conf
set +a
```
