# Performance - Analyse für Hash - Index

## Beschreibung

Es wird die **Performance vom Hash-Index** (mit Memory Storage Engine) analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ.

## Zielsetzung
Untersucht werden:
- Viele Hashkollisionen vs wenige Hashkollisionen erzwingen => unterschiedliche Selektivität
- Performance von Select - Queries
    - Ein Beispiel mit komplettem Index (1) => [full_match.lua](Scripts/query_differences/query_differences_select/full_match.lua)
    - Nur Nachname (2) => [leftmost_prefix.lua](Scripts/query_differences/query_differences_select/leftmost_prefix.lua)
    - Nachname + Vorname mit Like + Order by BDay (3) => [exact_with_prefix.lua](Scripts/query_differences/query_differences_select/exact_with_prefix.lua)
    - Nachname + Vorname + BDay als Range (4) => [combined_match_with_range.lua](Scripts/query_differences/query_differences_select/combined_match_with_range.lua)

## Durchführung: Ausführung des Benchmarks
Führe die folgenden Scripts aus, um die Benchmarks mit den korrekten Pfaden und Parametern zu starten.

### Code für Selektivität Vergleich:
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Hash/Output" \
  -var '{"prob":[25,10,5,1]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Hash/Scripts/selectivity_changes": {"vars": "prob"}
  }'
```

### Code unterschiedliche Select - Queries
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Hash/Output" \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Hash/Scripts/query_differences": {}
  }'
```

### Code unterschiedliche Select - Queries ohne Index (zum Vergleich)
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Hash/Output" \
  -var '{"no":["index"]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Hash/Scripts/query_differences": {
      "vars": "no"
    }
  }'
```

### Nur Graphen erstellen für Select - Queries (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Hash/Output
```