# Performance von Partitioning
## Beschreibung

## Datenbankstruktur

## Zielsetzung
Untersucht werden:
- **Join-Performance**: Wie beeinflusst der FK-Datentyp die Geschwindigkeit von Join-Abfragen?
- **Insert-Performance**: Wie wirken sich FK-Typen auf die Geschwindigkeit von Insert-Operationen aus?

Die Ergebnisse helfen, fundierte Entscheidungen zur Datenbankgestaltung zu treffen.

## Durchführung: Ausführung des Benchmarks

Führe das folgende Script aus, um die Benchmarks mit den korrekten Pfaden und Parametern auszuführen.

### Code für Range-Partitionierung:
```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output" \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/without_partitioning": {
      "selects": ["without_range_pruning"]
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/range_partitioning": {}
  }'
```

### Code für Hash-Partitionierung:
```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output" \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/without_partitioning": {
      "selects": ["without_hash_pruning","without_hash_pruning_range"]
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/hash_partitioning": {}
  }'
```

### Code für List-Partitionierung:
```bash
cd ../..
cd Tools
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
cd Tools
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Output
```