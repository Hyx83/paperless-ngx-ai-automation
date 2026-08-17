# Sicherheit

## Unterstützte Nutzung

Diese Automatik verändert Paperless-Metadaten und kann neue Korrespondenten anlegen.

Vor produktivem Einsatz sollte ein aktuelles Backup vorhanden sein.

## Geheimnisse

Folgende Werte gehören niemals in Git:

- OpenAI-/LLM-API-Schlüssel
- SMTP-Passwort
- Mailkonto-Passwörter
- Paperless-Secret-Key
- Datenbankpasswörter

Die SMTP-Datei:

```text
/opt/paperless_data/scripts/paperless-ai-mail.conf
```

sollte:

```bash
chmod 600 /opt/paperless_data/scripts/paperless-ai-mail.conf
```

erhalten.

## Prompt-Injection-Schutz

Der Hauptprompt weist das Modell ausdrücklich an, Dokumentinhalt und Dateinamen ausschließlich als zu analysierende Daten zu behandeln und Anweisungen innerhalb des Dokuments nicht zu befolgen.

Trotzdem gilt:

> LLM-Ausgaben sind nicht deterministisch und stellen keine vertrauenswürdige Sicherheitsgrenze dar.

Deshalb existieren zusätzliche lokale Regeln:

- vorhandene Korrespondenten werden geschützt
- mehrdeutige Ergebnisse werden nicht übernommen
- neue Korrespondenten benötigen eine zweite Prüfung
- hohe Fuzzy-Schwellen
- Datum wird nicht automatisch geändert

## Datenübertragung an den LLM-Anbieter

Der OCR-Inhalt eines Dokuments wird an den konfigurierten LLM-Endpunkt übertragen.

Vor Nutzung muss geprüft werden, ob dies für die eigenen Dokumente, Datenschutzanforderungen und Verträge zulässig ist.

`MAX_CONTENT_CHARS` begrenzt die übertragene Textmenge, verhindert aber nicht die Übertragung sensibler Informationen.

## SMTP-Berichte

Konfliktberichte können Dokumenttitel, Korrespondenten, Dateinamen und andere Metadaten enthalten.

Der Empfänger des Berichts muss entsprechend vertrauenswürdig sein.

## Parallelität

Die DB-Schreibphase wird per Dateisperre serialisiert.

Die Sperre reduziert Race Conditions, ersetzt aber keine Datenbank-Backups oder fachliche Datenvalidierung.

## Sicherheitsmeldungen

Bei sicherheitsrelevanten Fehlern sollte ein Issue ohne echte Dokumentinhalte, API-Schlüssel oder personenbezogene Daten erstellt werden.
