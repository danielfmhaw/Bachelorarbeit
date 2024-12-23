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

### Code für Null
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Output/Null" \
  -len "2,25" \
  -scripts:"/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Null/Scripts/null:true" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Null/Scripts/not_null:false"
```

### Code für Int/Char - Vergleich:

```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Output/Simpler" \
  -scripts:"/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Simpler/Scripts/int_column:false" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Simpler/Scripts/char_column:false"
```

### Code für Data Type Größenvergleich:

```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Output/Simpler" \
  -len "10,255" \
  -scripts:"/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/char:true" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/int:true" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Smaller/Scripts/varchar:true"
```


#### Notes
Allgemein gilt bei Datentypen, dass kleiner besser ist, weshalb man den kleinstmöglichen Datentypen wählen sollte, den man speichern kann und der die vorhandenen Daten entsprechend repräsentieren kann.
Dadurch wird weniger Speicherplatz (In-Memory und CPU-Cache) in Anspruch genommen, weshalb die Abfragen meistens schneller sind.
Ein weiterer Vorteil, der für die Benutzung von kleinstmöglichen Typen spricht, ist die einfache Typveränderung, wenn man die vorhandenen Daten falsch eingeschätzt hat und nachträglich ein größerer Datentyp benötigt wird.
%TODO (Daniel): add grafix and analysis


Ein weiterer allgemeiner Leitsatz ist, dass ein einfacherer Datentyp gut ist, denn es werden weniger CPU-Zyklen benötigt, um Operationen auf einfacheren Datentypen zu verarbeiten.
Beispielweise ist Integer einfacher zu verarbeiten als Character, da Character Sets und Sortierregeln den Character-Vergleich erschweren.
%TODO (Daniel): add grafix and analysis

Generell bringt es auch Performancegewinne, wenn man NULL vermeidet, wenn es möglich ist.
Viele Tabellen enthalten NULLABLE Spalten, selbst wenn die Anwendung kein NULL (Fehlen eines Wertes) speichern muss, da dies die Standardeinstellung ist.
Daher ist am besten solche Spalten bei der Tabellenerstellung mit dem Identifier NOT NULL zu definieren.
Wenn allerdings NULL-Werte gespeichert werden soll, dann sollte der Identifier nicht genutzt werden und für MySQL ist es dann schwieriger Abfragen zu optimieren, da durch Indizes, Indexstatistiken und Wertevergleiche komplizierter werden.
Dadurch benötigen sie auch mehr Speicherplatz und erfordern eine spezielle Verarbeitung innerhalb von MySQL.
Das liegt daran, dass indizierte nullable Spalten ein zusätzliches Byte pro Eintrag gebrauchen und das kann dazu führen, dass ein Index mit fester Größe in einen variablen Index umgewandelt wird.
Die Leistungsverbesserung, die durch die Änderung von NULL-Spalten in NOT NULL erzielt wird, ist in der Regel gering, aber bei der Verwendung von Indizes sollte besonders darauf geachtet werden.
%TODO (Daniel): add grafix and analysis

### Nur Graphen erstellen für Null (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Output/Null \
  2,25 \
 "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Null/Scripts/null:true" \
 "/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Data_Types/Null/Scripts/not_null:false" 
```