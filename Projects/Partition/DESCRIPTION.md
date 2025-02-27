# Performance von Partitioning

## Beschreibung

Es wird der Performance - Unterschied zwischen unterschiedlichen den Partitionstypen (Range, List, Hash und Key) analysiert.
Für die Typen Range, List und Hash gibt es jweils einen Vergleich mit Partition vs ohne Partition.
Und dann gibt es noch einen Vergleich zwischen RANGE COLUMNS und RANGE und einen Vergleich zwischen Hash und Key-Partitioning.

## Datenbankstruktur

Das Projekt verwendet zwei Tabellen: **KUNDE** und **BESTELLUNG**.
Es gibt teilweise leichte Anpassungen für die jeweiligen Tabellen (je nach Typ).
Außerdem wird auch der Primärschlüssel der Kundentabelle verändert und es werden keine Foreign Constraints definiert.

## Zielsetzung
Untersucht werden:
- **RANGE COLUMNS vs RANGE**: Gibt es einen Unterschied in der Performance oder sind beide gleich? 
- **HASH vs KEY - Partitioning**: Gibt es einen Unterschied in der Performance oder sind beide gleich?
- **RANGE-Partitioning vs without**: Mit welchen Operatoren funktioniert Pruning besser/schlechter (für Zeitabfragem) und wie ist der Vergleich mit einer nicht partitionierten Tabelle
- **LIST-Partitioning vs without**: Mit welchen Operatoren funktioniert Pruning besser/schlechter (ein Land oder mehrere) und wie ist der Vergleich mit einer nicht partitionierten Tabelle
- **KEY-Partitionierung**: Wie verhält sich die Key-Partitionierung mit einer unterschiedlichen Anzahl an Partitionen (5, 50, 500) und wie ist der Vergleich mit einer nicht partitionierten Tabelle

## Durchführung: Ausführung des Benchmarks
Führe die folgenden Scripts aus, um die Benchmarks mit den korrekten Pfaden und Parametern zu starten.

### Code für Range-Partitionierung:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output" \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/without_partitioning": {
      "selects": ["without_range_failing_pruning","without_range_primary_key"]
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/range_partitioning": {}
  }'
```

### Code für Range-Partitionierung-Vergleich zwischen RANGE COLUMNS and only RANGE (nicht in CI/CD enthalten, also pattern.json):
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output" \
  -var '{"type":["range_columns","only_range"]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/range_partitioning": {
      "vars": "type",
      "selects": ["with_primary_key","with_pruning"]
    }
  }'
```

### Code für Hash-Partitionierung mit Range:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output" \
  -var '{"partitions_size":[5,50,500]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/without_partitioning": {
      "selects": ["without_hash_pruning_range"]
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/hash_partitioning": {
      "vars": "partitions_size"
    }
  }'
```

### Vergleich zwischen Hash-und Key-Partitionierung (nicht in CI/CD enthalten, also pattern.json):
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output" \
  -var '{"type":["hash","key"],"partitions_size":[5,100]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/hash_partitioning": {
      "vars": "type,partitions_size"
    }
  }'
```

### Code für List-Partitionierung:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output" \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/without_partitioning": {
      "selects": ["without_list_pruning_simple","without_list_pruning_multiple"]
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/list_partitioning": {}
  }'
```

```bash
cd ../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output
```