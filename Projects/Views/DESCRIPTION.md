# Performance - Analyse für Views

## Beschreibung

Es wird die **Performance** von unterschiedlichen **Relationen und Views** analysiert.

## Datenbankstruktur

Das Projekt verwendet zwei Tabellen: **KUNDE** und **BESTELLUNG**.
Zusätzlich haben die virtuellen oder materialisierten Sichten folgende Spalten: Jahr, Land, Gesamtumsatz  

## Zielsetzung
Untersucht werden:
- **Without View vs. Virtual View vs. With Trigger**: Verschiedene Ansätze in MySQL (mit Trigger, da es sonst keine native Implementierung gibt)
- **With Trigger in MySQl vs. With Trigger in Postgres vs. Materialisierte Sicht **: Benchmark mit MySQL und Postgres zum Vergleich vs materialisierte Sicht 

## Durchführung: Ausführung des Benchmarks
Führe die folgenden Scripts aus, um die Benchmarks mit den korrekten Pfaden und Parametern zu starten.

### Code für View-Vergleich:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Output" \
  -scripts '{
   "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/without_view": {},
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/virtual_view": {},
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/with_trigger": {}
  }'
```

### Code mit Materialized View-Vergleich:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Output" \
  -var '{"refresh":["every","once"]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/with_trigger": {},
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/with_trigger_pg": {
      "db": ["postgres"]
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/mat_view": {
      "vars": "refresh",
      "db": ["postgres"]
    }
  }'
```

### Nur Graphen erstellen für Select - Queries (log und csv- files müssen schon bestehen)
```bash
cd ../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Output
```