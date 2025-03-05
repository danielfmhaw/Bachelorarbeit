# Performance von Join-Abfragen

## Beschreibung

Es wird die **Performance von Join-Abfragen** und **Insert-Operationen** unter Verwendung unterschiedlicher Datentypen für den Join-Operator untersucht. Ziel ist es, die Auswirkungen verschiedener Designs auf die Effizienz dieser Operationen zu analysieren.

## Datenbankstruktur

Das Projekt verwendet zwei Tabellen: **KUNDE** und **BESTELLUNG**. Die Konfiguration des **Foreign Keys (FK)** unterscheidet sich dabei, um die Performance verschiedener Ansätze zu testen.

### Tabelle: KUNDE
Die Tabelle enthält Informationen zu Kunden:

```sql
CREATE TABLE KUNDE (
    KUNDEN_ID     INT AUTO_INCREMENT PRIMARY KEY, -- ID für FK-Referenz
    NAME          VARCHAR(255),
    GEBURTSTAG    DATE,
    ADRESSE       VARCHAR(255),
    STADT         VARCHAR(100),
    POSTLEITZAHL  VARCHAR(10),
    LAND          VARCHAR(100),
    EMAIL         VARCHAR(255) UNIQUE,
    TELEFONNUMMER VARCHAR(20)
);
```

### Tabelle: BESTELLUNG
Die Tabelle speichert Bestellinformationen und ist über einen Foreign Key mit der Tabelle **KUNDE** verknüpft:

```sql
CREATE TABLE BESTELLUNG (
    BESTELLUNG_ID INT PRIMARY KEY,
    BESTELLDATUM  DATE,
    ARTIKEL_ID    INT,
    FK_KUNDEN     INT NOT NULL,
    UMSATZ        INT,
    FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDE (KUNDEN_ID)
);
```

## Zielsetzung
Untersucht werden:
- **Join-Performance**: Wie beeinflusst der FK-Datentyp die Geschwindigkeit von Join-Abfragen?
- **Insert-Performance**: Wie wirken sich FK-Typen auf die Geschwindigkeit von Insert-Operationen aus?

Die Ergebnisse helfen, fundierte Entscheidungen zur Datenbankgestaltung zu treffen.

### Schritte:

1. Navigiere in das Verzeichnis `Tools`, wo sich das Script befindet.
2. Führe das Script `sysbench_script.sh` aus und übergebe die erforderlichen Parameter.

## Durchführung: Ausführung des Benchmarks
Führe die folgenden Scripts aus, um die Benchmarks mit den korrekten Pfaden und Parametern zu starten.

### Code für Join Type - Vergleich:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Join_Typ/Output" \
  -var '{"length":[4, 16]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Join_Typ/Scripts/varchar_queries": {
      "vars": "length"
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Join_Typ/Scripts/int_queries": {
      "vars": "length"
    }
  }'
```

```bash
cd ../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Join_Typ/Output
```