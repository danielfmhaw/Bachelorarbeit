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
      "selects": ["without_range_failing_pruning","without_range_primary_key"]
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Partition/Scripts/range_partitioning": {}
  }'
```

### Code für Range-Partitionierung-Vergleich zwischen RANGE COLUMNS and only RANGE (nicht in CI/CD enthalten, also pattern.json):
```bash
cd ../..
cd Tools
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
cd Tools
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
cd Tools
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