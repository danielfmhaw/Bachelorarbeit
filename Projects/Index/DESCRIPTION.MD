# Vergleich von B - Tree - Index und Hash - Index

## Beschreibung

Es wird die Performance zwischen dem **B-Tree-Index** und dem **Hash - Index** analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ.

## Zielsetzung
Untersucht werden:
- Performance – Unterschied zwischen B-Tree-Index und dem Hash - Index
  - Hash - Index hat nur 4 Select-Skripte
  - B - Tree führt auch diese 4 Stück aus
  - Da die Skript-Namen von beiden gleich sein würden, müssen wir einen Variablen jeweils hinzufügen

## Durchführung: Ausführung des Benchmarks
Führe das folgende Script aus, um die Benchmarks mit den korrekten Pfaden und Parametern zu starten.

### Code Hash-Tree vs. B-Tree
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Output" \
  -var '{"b_tree":["index"],"hash":["index"]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/B_Tree/Scripts/query_differences": {
      "vars": "b_tree",
      "selects": ["combined_match_with_range.lua","exact_with_prefix.lua","full_match.lua","leftmost_prefix.lua"]
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/Hash/Scripts/query_differences": {
      "vars": "hash"
    }
  }'
```