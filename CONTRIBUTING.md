# Beitragen

Beiträge sind willkommen, sollten aber die konservative Sicherheitslogik nicht abschwächen.

## Entwicklungsprinzipien

Änderungen sollten insbesondere folgende Regeln respektieren:

- vorhandene manuelle Korrespondenten nicht automatisch überschreiben
- Dokumentdatum nicht automatisch ändern
- neue Korrespondenten nicht ohne ausreichende Bestätigung anlegen
- Dry-Run muss erhalten bleiben
- Post-Consume darf Paperless nicht unnötig blockieren
- parallele Verarbeitung darf die DB-Schreibsicherheit nicht umgehen
- Geheimnisse dürfen nicht ins Repository gelangen

## Test vor Pull Request

Mindestens:

```bash
python3 -m py_compile paperless_ai_recheck.py
```

Danach in einer Testinstanz:

```bash
cd /opt/paperless/src
DOCUMENT_IDS=23 APPLY=0 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

Zusätzlich sollten bekannte Problemklassen getestet werden:

- echter neuer Korrespondent
- vorhandener korrekter Korrespondent
- Konflikt mit manuell gesetztem Korrespondenten
- mehrere Organisationen im Dokument
- Gerätehersteller statt Dokumentaussteller
- Krankenkasse/Versicherung nur als erwähnte Stelle
- Scan mit generischem Titel
- bereits sinnvoll benanntes Dokument

## Stil

- Python 3 Typannotationen bevorzugen
- Änderungen klein und nachvollziehbar halten
- sicherheitsrelevante Entscheidungspfade dokumentieren
- keine Zugangsdaten in Beispielen
