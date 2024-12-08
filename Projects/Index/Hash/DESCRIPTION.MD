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
    - Nachname + Vorname mit Range (3) => [partial_match_range_query.lua](Scripts/query_differences/query_differences_select/partial_match_range_query.lua)
    - Nachname + Vorname + BDay als Range (4) => [combined_match_with_range.lua](Scripts/query_differences/query_differences_select/combined_match_with_range.lua)


### Code für Selektivität Vergleich:
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/Hash/Output/selectivity_changes" \
  -len "10,100,500" \
  -script:"/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/Hash/Scripts/selectivity_changes:true" 
```

### Code unterschiedliche Select - Queries
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/Hash/Output/query_differences" \
  -script:"/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/Hash/Scripts/query_differences:false" 
```