# Performance - Unterschied zwischen Not Null und Null Spalten

## Beschreibung

Es wird der Performance - Unterschied zwischen Not Null und Null analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ.
Dieses Mal werden einmal alle Spalten als [**NOT_NULL**](Scripts/not_null) definiert und einmal als [**NULL**](Scripts/with_null). 

## Zielsetzung
Untersucht werden:
- Performance – Unterschied zwischen Not Null und Null Spalten
- Unterschiedliche Abfragen (group by, count etc.) auf den beiden Tabellen

### Code für Null
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Null/Output" \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Null/Scripts/with_null": {},
    "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Null/Scripts/not_null": {}
  }'
```
### Nur Graphen erstellen für Null (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Null/Output
```
