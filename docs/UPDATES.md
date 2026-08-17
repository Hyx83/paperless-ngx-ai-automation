# Updates und Wartung

## Grundsatz

Die KI-Automation liegt bewusst unter:

```text
/opt/paperless_data/scripts/
```

und nicht direkt im Paperless-Quellbaum.

Dadurch ist sie besser von Paperless-Anwendungsupdates getrennt.

## Vor Paperless-Updates

Empfohlen:

```bash
cp -a /opt/paperless_data/scripts /root/paperless-ai-scripts-backup-$(date +%Y%m%d-%H%M%S)
```

Zusätzlich sollte die Paperless-Datenbank regulär gesichert werden.

## Nach Paperless-Updates

Prüfen:

```bash
cd /opt/paperless/src
uv run -- python manage.py shell -c "from paperless_ai.client import AIClient; print('AIClient OK')"
```

Dann Dry-Run:

```bash
cd /opt/paperless/src
DOCUMENT_IDS=23 APPLY=0 uv run -- python manage.py shell < /opt/paperless_data/scripts/paperless_ai_recheck.py
```

Post-Consume:

```bash
DOCUMENT_ID=23 AI_POST_CONSUME_APPLY=0 /opt/paperless_data/scripts/paperless-ai-post-consume.sh
```

## Abhängigkeit vom Paperless-AI-Client

Das Skript importiert:

```python
from paperless_ai.client import AIClient
```

Ändert Paperless intern diese API, kann eine Anpassung erforderlich werden.

## Keine dauerhaften Quellcode-Patches bevorzugen

Lokale Änderungen unter:

```text
/opt/paperless/src/
```

können bei Updates überschrieben werden.

Soweit möglich sollten Anpassungen über:

- Paperless-Konfiguration
- das eigene Post-Consume-Skript
- eigene Wrapper
- Umgebungsvariablen

erfolgen.

## Versionsstrategie

Vor jeder produktiven Aktualisierung:

1. neue Skriptversion unter anderem Dateinamen ablegen
2. Syntax prüfen
3. einzelne Dokumente im Dry-Run testen
4. Problemfälle testen
5. erst danach Produktivdatei ersetzen

Version prüfen:

```bash
grep -n '^# Version:' /opt/paperless_data/scripts/paperless_ai_recheck.py | head -1
```
