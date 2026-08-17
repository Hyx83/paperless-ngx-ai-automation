# Changelog

Dieses Changelog dokumentiert die Entwicklung von der ersten funktionsfähigen Fassung bis zum aktuellen Stand.

> **Hinweis:** Der aktuelle Repository-Quellstand ist v4.5. Die älteren Versionen werden hier anhand der während der Entwicklung dokumentierten Funktionsstände beschrieben. Exakte historische Quellcode-Snapshots von v1 bis v4.4 wurden nicht als Release-Artefakte archiviert.

## 4.5

### Neu

- Konflikt-CSV kann automatisch per SMTP versendet werden
- Mail wird nur versendet, wenn mindestens ein Prüffall oder technischer Fehler vorhanden ist
- leere Konflikt-CSV kann automatisch gelöscht werden
- mehrere Empfänger werden unterstützt
- SMTP-Modi `starttls`, `ssl` und `none`
- SMTP-Fehler beeinflussen die Dokumentverarbeitung nicht
- CSV-Dateinamen sind bei parallelen Prozessen kollisionssicher
- 3-Slot-Worker lädt eine separate geschützte Mail-Konfiguration

### Hintergrund

Nach der Einführung einer reinen Konflikt-CSV in v4.4 entstand der Wunsch, manuelle Prüffälle nicht mehr aktiv auf dem Server suchen zu müssen.

---

## 4.4

### Neu

- CSV enthält nur noch Fälle mit manuellem Prüfbedarf
- technische Fehler werden weiterhin immer protokolliert
- erfolgreiche Standardfälle werden nicht mehr in die CSV geschrieben

### Als Prüffall gelten

- mehrdeutige oder mehrere Korrespondenten
- Konflikt mit vorhandenem Korrespondenten
- zweite KI-Prüfung verwirft ersten Vorschlag
- kein sicherer Korrespondent bei leerem Korrespondentenfeld
- technische Fehler

### Hintergrund

Das vorherige vollständige CSV-Protokoll war für den Alltagsbetrieb zu umfangreich. Ziel wurde ein Arbeitsbericht statt eines Vollprotokolls.

---

## 4.3

### Neu

- asynchroner Post-Consume-Hook über `systemd-run`
- Paperless wartet nicht mehr auf die KI-Verarbeitung
- parallele KI-Verarbeitung
- globale KI-Slots
- Ausbau auf drei parallele KI-Jobs
- DB-Schreibphase wird separat per Dateisperre serialisiert
- paralleler manueller Batchlauf
- `DELAY_SECONDS=0` im Post-Consume-Worker

### Sicherheitsänderung

Nicht der gesamte KI-Prozess wird gesperrt, sondern nur die kurze Schreibphase.

Damit können mehrere langsame LLM-Abfragen gleichzeitig laufen, ohne dass neue Korrespondenten unkontrolliert parallel angelegt werden.

### Hintergrund

Mit stärkeren Modellen und zweiter Verifikationsabfrage wurde der serielle Betrieb zu langsam. Der eigentliche Paperless-Import sollte außerdem nicht auf die KI warten.

---

## 4.2

### Neu

- Mehrfach-Korrespondentenerkennung verbessert
- Klammerinhalte werden bei der Komma-Erkennung ignoriert

### Beispiel

Vorher konnte:

```text
Kaufland (Filiale 3970, Herford)
```

fälschlich als mehrere Korrespondenten behandelt werden.

Ab v4.2 gilt das Komma innerhalb der Klammer nicht mehr als Trennzeichen.

Mehrfachangaben wie:

```text
ARD, ZDF, Deutschlandradio
```

bleiben weiterhin geschützt und werden nicht automatisch übernommen.

---

## 4.1

### Neu

- zweite separate KI-Prüfung für neue oder neu zu setzende Korrespondenten
- neue Korrespondenten werden nur nach Bestätigung übernommen
- OCR-verdächtige oder substantiv unsichere Korrespondenten können verworfen werden
- neue Korrespondenten und Dokumentänderung werden atomisch gespeichert
- Titelbereinigung wird konservativer
- geschützte vorhandene Titel bleiben vollständig unangetastet

### Behobene Fehler

- eine Korrespondenten-Neuanlage konnte im APPLY-Modus fälschlich nicht als Änderung erkannt werden
- geschützte Titel konnten durch nachgelagerte Titelbereinigung dennoch verändert werden

### Hintergrund

Die wichtigste verbleibende Fehlerklasse aus v3 waren **plausibel klingende, aber sachlich falsche Einzel-Korrespondenten**.

Beispiele aus der Testphase:

- eine Krankenkasse wurde bei einer Lohnsteuerbescheinigung als Aussteller erkannt
- ein Medizingerätehersteller wurde bei einem EKG als Korrespondent erkannt
- ein OCR-fehlerhafter Organisationsname hätte neu angelegt werden können

Die zweite Prüfung wurde genau für diese Klasse eingeführt.

---

## 4.0

### Neu

- konservative Korrespondentenlogik
- vorhandene Korrespondenten werden niemals automatisch überschrieben
- bestehende sinnvolle Titel werden geschützt
- Datum wird nicht mehr automatisch verändert
- Mehrfach-Korrespondenten werden blockiert
- neue Korrespondenten werden konservativer angelegt

### Grundsatzwechsel

Ab v4 lautet die Priorität:

```text
Korrektheit > Vollständigkeit
```

Ein fehlender Korrespondent ist besser als ein falscher.

---

## 3

### Neu

- Fuzzy-Schwelle für Korrespondenten auf `0.93` angehoben
- vorhandener Korrespondent wird bei abweichendem KI-Vorschlag geschützt
- Konflikte werden explizit ausgewiesen
- Mehrfach-Korrespondenten werden blockiert
- auch eine einzelne kommaseparierte KI-Zeichenkette kann als Mehrfachangabe erkannt werden
- Substring-Matching wurde begrenzt
- Einwort-Titel werden standardmäßig verworfen, außer für eine kleine Whitelist
- Prompt fordert höchstens einen echten Aussteller/Absender
- Organisationen, die nur erwähnt werden, sollen nicht als Korrespondent gelten
- Dry-Run simuliert neu anzulegende Korrespondenten, damit spätere Dokumente im selben Lauf sie wiederverwenden können
- Dateinamensvorschau wurde korrigiert

### Wichtige Regressionen, die damit verhindert wurden

```text
Stadt Porta Westfalica
```

durfte nicht fälschlich mit:

```text
Stadtwerke Porta Westfalica GmbH
```

zusammengeführt werden.

Ein vorhandener Korrespondent wie:

```text
Geildgeier GmbH
```

durfte bei einer Arbeitnehmerkündigung nicht durch den KI-Vorschlag:

```text
Max Mustermann
```

ersetzt werden.

---

## 2

### Neu

- **keine automatische Datumsänderung mehr**
- KI-Datumswerte werden nur noch protokolliert
- Titel werden nur noch ersetzt, wenn der vorhandene Titel wie Scan-/Importname wirkt oder dem Originaldateinamen entspricht
- sinnvoll manuell gesetzte Titel werden geschützt
- Korrespondentenabgleich in beide Richtungen verbessert
- Rechtsformen werden beim Vergleich teilweise normalisiert
- neue Korrespondenten können bei eindeutigem Einzelvorschlag angelegt werden
- virtuelle Korrespondenten im Dry-Run
- Dateinamensvorschau über Paperless' eigene Dateinamenslogik

### Hintergrund

Die erste Fassung zeigte, dass semantisch plausible KI-Daten nicht automatisch gleichbedeutend mit dem gewünschten Paperless-Dokumentdatum sind.

Beispiel:

```text
Paperless-Datum: 2022-06-22
KI erkennt:      2002-07-13
```

Das KI-Datum konnte historisch korrekt sein, aber trotzdem war eine automatische Änderung ohne fachliche Prüfung zu riskant.

---

## 1

### Erste funktionsfähige Fassung

- Batchlauf über vorhandene Paperless-Dokumente
- OCR-Inhalt wird über Paperless' AIClient an das konfigurierte LLM gesendet
- KI schlägt Titel vor
- KI schlägt Korrespondenten vor
- KI schlägt Datumswerte vor
- Dry-Run mit CSV-Protokoll
- optionaler APPLY-Modus
- Dateinamensvorschau

### Schwächen

- Datum konnte automatisch verändert werden
- Titel- und Korrespondentenschutz war noch nicht ausreichend
- Korrespondenten konnten zu aggressiv zusammengeführt oder neu angelegt werden
- es gab noch keine zweite Verifikation
- keine Parallelisierung
- kein Post-Consume-Betrieb
- CSV war ein Vollprotokoll und kein reiner Prüfbericht

Diese erste Fassung war bewusst ein explorativer Batch-Prototyp und noch nicht für unbeaufsichtigten Dauerbetrieb gedacht.
