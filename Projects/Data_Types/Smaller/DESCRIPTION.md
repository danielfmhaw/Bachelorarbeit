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

### Code für Number Größenvergleich:
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Output" \
  -var '{"datatyp":["smallint_13","smallint_16","mediumint_24","int_32","bigint_64","decimal_65"]}' \
  -scripts:'["/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/int:datatyp"]'
```

### Nur Graphen erstellen für Number Größenvergleich (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Output
```

### Code für String Größenvergleich:
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Output" \
  -var '{"typ":["char_4","char_64","varchar_4","varchar_64"],"num_rows":[250]}' \
  -scripts:'["/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/string:typ;num_rows"]'
```

### Code für Anteil der einfügten Zeichen bei Länge von 255:
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Output" \
  -var '{"typ":["char_255","varchar_255"],"length":[56,240],"num_rows":[250]}' \
  -scripts:'["/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/string:typ;length;num_rows:Total Time (s);Write (noq)::Time (s);Threads;Writes:"]'
```

### Nur Graphen erstellen für String - Größenvergleich (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Output
```

#### Notes
Allgemein gilt bei Datentypen, dass kleiner besser ist, weshalb man den kleinstmöglichen Datentypen wählen sollte, den man speichern kann und der die vorhandenen Daten entsprechend repräsentieren kann.
Dadurch wird weniger Speicherplatz (In-Memory und CPU-Cache) in Anspruch genommen, weshalb die Abfragen meistens schneller sind.
Ein weiterer Vorteil, der für die Benutzung von kleinstmöglichen Typen spricht, ist die einfache Typveränderung, wenn man die vorhandenen Daten falsch eingeschätzt hat und nachträglich ein größerer Datentyp benötigt wird.