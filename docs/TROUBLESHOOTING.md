# Fehlerbehebung

## Dokument wird analysiert, aber nicht geändert

Prüfen:

```text
APPLY=0
```

Im Log erscheint dann:

```text
DRY-RUN, keine Änderung
```

Für den Live-Betrieb:

```ini
AI_POST_CONSUME_APPLY=1
```

## Post-Consume passiert gar nicht

Konfiguration prüfen:

```bash
grep -E '^(PAPERLESS_POST_CONSUME_SCRIPT|AI_POST_CONSUME_APPLY)=' /opt/paperless/paperless.conf
```

Skript prüfen:

```bash
ls -l /opt/paperless_data/scripts/paperless-ai-post-consume.sh
```

Paperless-Dienste neu laden:

```bash
systemctl restart paperless-task-queue paperless-consumer
```

Paperless-Log:

```bash
journalctl -u paperless-task-queue -u paperless-consumer -f
```

## Hook ist langsam

Messen:

```bash
time DOCUMENT_ID=23 AI_POST_CONSUME_APPLY=0 /opt/paperless_data/scripts/paperless-ai-post-consume.sh
```

Der asynchrone Wrapper sollte schnell zurückkehren. Lange Laufzeiten deuten darauf hin, dass noch ein alter synchroner Wrapper verwendet wird.

Prüfen:

```bash
grep -nE 'systemd-run|paperless-ai-worker|uv run' /opt/paperless_data/scripts/paperless-ai-post-consume.sh
```

Der Post-Consume-Wrapper sollte `systemd-run` verwenden und nicht selbst den vollständigen Python-Lauf abwarten.

## KI läuft erst deutlich später

Bis zu drei KI-Jobs können gleichzeitig laufen.

Sind alle Slots belegt, wartet der nächste Worker.

Log:

```bash
tail -f /opt/paperless_data/data/log/paperless-ai-post-consume.log
```

## Import selbst ist langsam

Der KI-Hook läuft erst nach erfolgreichem Paperless-Import.

Lange Importzeiten können daher unter anderem durch OCR oder PDF-Nachbearbeitung entstehen.

Prüfen:

```bash
journalctl -u paperless-task-queue -u paperless-consumer -f
```

```bash
ps -eo pid,pcpu,pmem,etime,cmd --sort=-pcpu | head -25
```

Typische Prozesse:

```text
tesseract
ocrmypdf
ghostscript
pikepdf
```

## KI liefert 500

Ein HTTP-500 in Paperless ist häufig nur die sichtbare Folge eines Fehlers des eigentlichen LLM-Aufrufs.

Vorgehen:

1. vollständigen Python-/Paperless-Trace lesen
2. tatsächlichen HTTP-Status des LLM-Anbieters ermitteln
3. Modellkompatibilität prüfen
4. Endpunkt nicht blind verändern
5. einzelnes Dokument im Dry-Run testen

Modellwechsel:

```bash
cd /opt/paperless/src
DOCUMENT_IDS=23 APPLY=0 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

## Korrespondent wird nicht gesetzt

Das kann beabsichtigt sein.

Beispiele:

```text
NICHT GESETZT: zweite KI-Prüfung hat Korrespondenten nicht sicher bestätigt
```

oder:

```text
MEHRDEUTIG
```

Die Automatik ist bewusst konservativ.

## Vorhandener Korrespondent wird nicht ersetzt

Das ist eine Sicherheitsfunktion.

Beispiel:

```text
aktuell: Privat
KI: RVZ Ostwestfalen eGbR
→ KONFLIKT
→ Privat bleibt
```

Manuelle Entscheidungen haben Vorrang.

## SMTP-Mail kommt nicht an

Konfiguration:

```bash
cat /opt/paperless_data/scripts/paperless-ai-mail.conf
```

Rechte:

```bash
stat -c '%a %n' /opt/paperless_data/scripts/paperless-ai-mail.conf
```

Sollte typischerweise sein:

```text
600
```

Im KI-Log nach folgenden Meldungen suchen:

```text
E-Mail-Bericht gesendet
WARNUNG: Konfliktbericht konnte nicht per E-Mail gesendet werden
```

Es wird **keine Mail** gesendet, wenn kein Prüffall vorhanden ist.

## Leere CSV fehlt

Bei:

```bash
AI_REPORT_DELETE_EMPTY_CSV=1
```

werden konfliktfreie CSV-Dateien absichtlich gelöscht.

## Doppelte Korrespondenten

Die DB-Schreibphase ist global gesperrt. Trotzdem sollte vor größeren Änderungen ein Backup der Paperless-Datenbank vorhanden sein.

Vorhandene Duplikate werden durch die Automatik nicht automatisch zusammengeführt.
