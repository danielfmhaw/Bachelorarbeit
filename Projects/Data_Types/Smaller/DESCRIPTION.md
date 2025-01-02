# Performance - Unterschied zwischen Int und Char

## Beschreibung

Es wird der Performance - Unterschied zwischen **Int und Char** analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ.

## Zielsetzung
Untersucht werden:
- Performance – Unterschied mit **unterschiedlichen Zeilenanzahl** insbesondere um die Geschwindigkeit für die Einfügeoperationen zu analysieren.
- Veranschaulichung der Performanceunterschiede für unterschiedliche **Select-Queries**:
  - Simple Where
  - With Sorting

### Code für Data Type Größenvergleich:
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Output/Smaller" \
  -var '{"length":[10,255]}' \
  -scripts:"/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/char:length" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/int:length" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/varchar:length"
```

### Nur Graphen erstellen für Data Type Größenvergleich (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Output/Smaller
```

#### Notes
Allgemein gilt bei Datentypen, dass kleiner besser ist, weshalb man den kleinstmöglichen Datentypen wählen sollte, den man speichern kann und der die vorhandenen Daten entsprechend repräsentieren kann.
Dadurch wird weniger Speicherplatz (In-Memory und CPU-Cache) in Anspruch genommen, weshalb die Abfragen meistens schneller sind.
Ein weiterer Vorteil, der für die Benutzung von kleinstmöglichen Typen spricht, ist die einfache Typveränderung, wenn man die vorhandenen Daten falsch eingeschätzt hat und nachträglich ein größerer Datentyp benötigt wird.