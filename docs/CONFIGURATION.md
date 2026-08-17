# Konfiguration

Die Hauptlogik wird über Umgebungsvariablen gesteuert.

## Allgemeine Variablen

| Variable | Standard | Bedeutung |
|---|---:|---|
| `APPLY` | `0` | `1` speichert Änderungen, `0` ist Dry-Run |
| `DOCUMENT_IDS` | leer | kommaseparierte Paperless-Dokument-IDs |
| `LIMIT` | `0` | maximale Dokumentanzahl; `0` = unbegrenzt |
| `DELAY_SECONDS` | `0.5` | Pause zwischen Dokumenten; der Post-Consume-Worker setzt `0` |
| `MAX_CONTENT_CHARS` | `8000` | maximale OCR-Zeichen für die KI |
| `REPLACE_EXISTING_TITLES` | `0` | erlaubt Überschreiben sinnvoller vorhandener Titel |
| `DB_WRITE_LOCK_PATH` | `/run/paperless-ai-db-write.lock` | globaler Lock für die DB-Schreibphase |

## Korrespondenten-Matching

| Variable | Standard | Bedeutung |
|---|---:|---|
| `CORRESPONDENT_FUZZY_THRESHOLD` | `0.93` | Mindestähnlichkeit für vorhandenen Korrespondenten |
| `CORRESPONDENT_MIN_GAP` | `0.05` | erforderlicher Abstand zwischen bestem und zweitbestem Treffer |
| `CORRESPONDENT_VERIFICATION_THRESHOLD` | `0.94` | Mindestähnlichkeit zwischen erster und zweiter KI-Bestätigung |

Im Prompt werden maximal 250 vorhandene Korrespondenten als Referenz aufgeführt.

## Post-Consume

In `paperless.conf`:

```ini
PAPERLESS_POST_CONSUME_SCRIPT=/opt/paperless_data/scripts/paperless-ai-post-consume.sh
AI_POST_CONSUME_APPLY=1
```

`PAPERLESS_POST_CONSUME_SCRIPT` ist eine offizielle Paperless-ngx-Konfiguration. Paperless übergibt dem Skript nach erfolgreichem Import unter anderem `DOCUMENT_ID`.

## LLM-Konfiguration

Das Skript nutzt den in Paperless konfigurierten `AIClient`. Der konkrete Modellname wird daher nicht im Skript fest verdrahtet.

Empfehlung:

- das Modell in Paperless konfigurieren
- den LLM-Basisendpunkt korrekt setzen
- API-Schlüssel ausschließlich in Paperless bzw. geschützter Konfiguration speichern
- Modellwechsel zunächst mit einem Dry-Run testen

Getestete Modelle im Referenzaufbau:

- `gpt-4.1-mini`
- `gpt-5.6-luna`

Modellverfügbarkeit und Preise können sich ändern. Aktuelle Informationen:

- https://developers.openai.com/api/docs/models
- https://developers.openai.com/api/docs/pricing

## SMTP-Bericht

Optional in:

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

Mögliche Werte für `AI_REPORT_SMTP_SECURITY`:

```text
starttls
ssl
none
```

Typische Kombinationen:

```text
587 + starttls
465 + ssl
```

Mehrere Empfänger können durch Komma oder Semikolon getrennt werden.

Rechte:

```bash
chmod 600 /opt/paperless_data/scripts/paperless-ai-mail.conf
```

Die Datei darf nicht in Git eingecheckt werden.

## Paperless-Leistungsparameter

Diese Parameter gehören zu Paperless selbst, nicht zum KI-Skript:

```ini
PAPERLESS_TASK_WORKERS=3
PAPERLESS_THREADS_PER_WORKER=2
```

Bei sechs für den Container sichtbaren CPU-Kernen ergibt das:

```text
3 Worker × 2 Threads = 6 Threads
```

Die optimale Einstellung hängt von CPU, RAM, Dokumentgröße und OCR-Last ab.

## OCR

Für gemischte Dokumentbestände ist typischerweise ein automatischer OCR-Modus sinnvoll. Änderungen an OCR-Parametern sollten separat getestet werden, weil sie Erkennungsqualität und Importdauer beeinflussen.

Die KI-Nachbearbeitung beginnt **erst nach erfolgreichem Paperless-Import**. Langsame OCR-Verarbeitung ist daher unabhängig von der LLM-Laufzeit zu betrachten.
