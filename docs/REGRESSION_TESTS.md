# Regressionstests

Die folgenden Dokumentklassen waren während der Entwicklung besonders wichtig. Sie sollten nach größeren Änderungen erneut im Dry-Run geprüft werden.

> Die IDs stammen aus einer konkreten Testinstanz und sind nur Beispiele. In anderen Installationen müssen eigene Dokumente mit denselben Problemklassen gewählt werden.

## Testfall A – normaler Händler

Beispiel:

```text
Kassenbon
Korrespondent: Kaufland
```

Erwartung:

- genau ein Händler
- zweite Prüfung bestätigt bei leerem Korrespondentenfeld
- kein Fehlalarm wegen Filialangaben in Klammern

Problemklasse:

```text
Kaufland (Filiale 3970, Herford)
```

darf nicht als mehrere Organisationen gelten.

---

## Testfall B – Lohnsteuerbescheinigung

Beispiel-Dokument-ID während der Entwicklung: `26`

Gefahr:

- Krankenkasse oder andere erwähnte Organisation wird als Aussteller missverstanden
- mehrere unterschiedliche Datumswerte im Dokument

Erwartung:

- nur tatsächlicher Arbeitgeber/Aussteller als Korrespondent
- zweite Prüfung muss Kandidat bestätigen
- Dokumentdatum niemals automatisch verändern

---

## Testfall C – Rundfunkbeitrag

Beispiel-Dokument-ID: `41`

Gefahr:

```text
ARD, ZDF, Deutschlandradio
```

kann als mehrere einzelne Korrespondenten interpretiert werden.

Erwartung:

- Mehrfachangabe wird nicht automatisch als neuer Korrespondent angelegt
- nur ein eindeutig erkannter tatsächlicher Beitragsservice darf übernommen werden

---

## Testfall D – medizinisches Gerät versus Praxis

Beispiel-Dokument-ID: `48`

Gefahr:

Ein Gerätehersteller steht prominent im EKG-Ausdruck.

Erwartung:

- Hersteller nicht automatisch als Aussteller
- tatsächliche Praxis/Klinik bevorzugen
- zweite Prüfung verwenden

---

## Testfall E – manuell gesetzter Korrespondent

Beispiel-Dokument-ID: `53`

Aktuell bewusst manuell gesetzt:

```text
Privat
```

KI kann einen anderen plausiblen Korrespondenten erkennen.

Erwartung:

```text
KONFLIKT
→ vorhandener Wert bleibt unverändert
```

Dieser Fall prüft, dass manuelle Paperless-Entscheidungen immer Vorrang haben.

---

## Testfall F – Arbeitnehmerkündigung

Beispiel-Dokument-ID: `67`

Vorhandener Korrespondent:

```text
Geldgeier GmbH
```

KI kann den Arbeitnehmer als Absender erkennen.

Erwartung:

- Geldgeier GmbH bleibt bestehen
- KI darf vorhandenen Wert nicht ersetzen

---

## Empfohlener Dry-Run

```bash
cd /opt/paperless/src
DOCUMENT_IDS=23,26,41,48,53,67 APPLY=0 \
uv run -- python manage.py shell \
< /opt/paperless_data/scripts/paperless_ai_recheck.py
```

## Was nach Änderungen geprüft werden sollte

- Titel sinnvoll?
- vorhandener Titel geschützt?
- vorhandener Korrespondent geschützt?
- Mehrfachorganisation erkannt?
- zweite Verifikation ausgeführt, wenn nötig?
- falscher Gerätehersteller vermieden?
- Datum nur protokolliert?
- Konflikt-CSV nur bei echtem Prüfbedarf?
