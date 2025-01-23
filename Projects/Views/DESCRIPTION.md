# Performance - Analyse für Views

## Beschreibung

Es wird die **Performance** von unterschiedlichen **Relationen und Views** analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ. 

## Zielsetzung
Untersucht werden:
- Performance – Unterschied mit **unterschiedlichen Zeilenanzahl**
- Veranschaulichung der Performanceunterschiede, **je nach Sortierung** des Index usw.
  - Index sollte funktionieren für: [column_prefix.lua](Scripts/query_differences/query_differences_select/column_prefix.lua), [combined_match_with_range.lua](Scripts/query_differences/query_differences_select/combined_match_with_range.lua), [exact_with_prefix.lua](Scripts/query_differences/query_differences_select/exact_with_prefix.lua), [full_match.lua](Scripts/query_differences/query_differences_select/full_match.lua),[leftmost_prefix.lua](Scripts/query_differences/query_differences_select/leftmost_prefix.lua), [range_values.lua](Scripts/query_differences/query_differences_select/range_values.lua)
  - Nicht funktionieren für: [not_leftmost.lua](Scripts/query_differences/query_differences_select/not_leftmost.lua), [range_with_like.lua](Scripts/query_differences/query_differences_select/range_with_like.lua), [skip_columns.lua](Scripts/query_differences/query_differences_select/skip_columns.lua)
    
### Code für High Count Vergleich:

```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Output" \
  -var '{"length":[1000],"refresh":["every","once"]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/virtual_view": {
      "vars": "length"
    },
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/with_trigger": {
      "vars": "length"
    }
  }'
```

Old with pgsql
```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Output" \
  -var '{"length":[1000],"refresh":["every","once"]}' \
  -scripts:'[
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/virtual_view:length",
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/with_trigger:length",
  "pgsql:/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/mat_view:length;refresh"
  ]'
```

```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Output" \
  -var '{"length":[1000],"refresh":["every","once"]}' \
  -scripts:'[
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Scripts/mat_view:length;refresh"
  ]'
```

### Nur Graphen erstellen für Select - Queries (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Views/Output
```