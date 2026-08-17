# Entscheidungslogik

## Ziel

Die Automatik soll nur dort selbstständig ändern, wo die Entscheidung ausreichend sicher ist.

Priorität:

```text
Korrektheit > Vollständigkeit > Geschwindigkeit
```

Ein leerer Korrespondent ist absichtlich besser als ein falscher Korrespondent.

## Titel

Ein Titel ist ersetzbar, wenn beispielsweise:

- kein Titel vorhanden ist
- der Titel wie ein Scan-/Importname aussieht
- der Titel generisch ist
- der Titel dem ursprünglichen Dateinamen entspricht

Beispiele:

```text
scan_2026_08_14T14_43_25
scan_21-05-2023-095748
IMG_1234
```

Sinnvolle bereits vorhandene Titel sind standardmäßig geschützt.

Die KI soll:

- kurze sachliche deutsche Titel erzeugen
- beschreiben, was das Dokument ist
- den Korrespondenten nicht unnötig im Titel wiederholen
- keine Informationen erfinden
- bei Unsicherheit den bestehenden Titel beibehalten

Einwort-Titel werden nur für eine konservative Whitelist typischer Dokumentarten akzeptiert.

## Korrespondenten

Als Korrespondent gilt ausschließlich der tatsächliche:

- Absender
- Aussteller
- Herausgeber

Nicht automatisch als Korrespondent gelten:

- Empfänger
- nur erwähnte Unternehmen
- Vertragspartner
- Zahlungsempfänger
- Gerätehersteller
- Versicherer oder Krankenkasse, wenn sie das konkrete Dokument nicht ausgestellt haben
- Organisationen aus Anlagen oder fremden Formularen

## Vorhandener Korrespondent

Ist bereits ein Korrespondent am Dokument gesetzt, wird dieser **niemals automatisch ersetzt**.

Die KI darf ihn bestätigen.

Weicht der KI-Vorschlag stark ab:

```text
KONFLIKT
→ vorhandener Wert bleibt unverändert
→ Eintrag in Konfliktbericht
```

Dadurch bleiben manuelle Entscheidungen geschützt.

## Neuer Korrespondent

Wenn noch kein Korrespondent gesetzt ist:

1. KI ermittelt höchstens einen Kandidaten.
2. Mehrfachangaben werden abgelehnt.
3. Kandidat wird gegen vorhandene Paperless-Korrespondenten verglichen.
4. Falls noch kein passender Eintrag existiert, wird eine zweite separate KI-Prüfung ausgeführt.
5. Nur bei erfolgreicher Bestätigung darf der Korrespondent gesetzt bzw. neu angelegt werden.

## Mehrdeutige Angaben

Beispiel:

```text
ARD, ZDF, Deutschlandradio
```

wird nicht automatisch übernommen.

Klammerinhalte werden bei der Mehrfacherkennung ignoriert, damit beispielsweise:

```text
Kaufland (Filiale 3970, Herford)
```

nicht fälschlich als mehrere Organisationen behandelt wird.

## Fuzzy-Matching

Rechtsformen und Schreibvarianten werden beim Vergleich teilweise normalisiert.

Beispiele:

```text
Deutsche Post
Deutsche Post AG
```

oder:

```text
Telekom
Telekom Deutschland GmbH
```

können als derselbe Korrespondent erkannt werden.

Die Schwellenwerte sind absichtlich hoch angesetzt.

## Datum

Die KI darf Datumswerte erkennen und protokollieren.

Das Skript führt jedoch **keine automatische Datumsänderung** durch.

Bevorzugt werden:

1. Ausstellungsdatum
2. Rechnungsdatum
3. Briefdatum
4. Bescheiddatum
5. eindeutig bezeichnetes Dokumentdatum

Nicht bevorzugt werden unter anderem:

- Scan-/Importdatum
- Fälligkeitsdatum
- Zahlungsdatum
- Geburtsdatum
- Vertragsbeginn/-ende
- Leistungszeitraum
- historische Datumsangaben

## Dateiname

Das Skript ändert die Dokumentdatei nicht direkt.

Es aktualisiert Paperless-Metadaten. Paperless generiert daraus anschließend den Dateinamen gemäß seiner eigenen Dateinamenskonfiguration.

Beispiel:

```text
2026/06/19.06.2026 - Sichere Kleidung GmbH - Lieferschein für Sicherheitsschuhe.jpg
```
