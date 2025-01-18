# Performance - Unterschied zwischen unterschiedlichen Datentypen (nummerisch und string)

## Beschreibung

Es wird der Performance - Unterschied zwischen **unterschiedlichen Datentypen**, einmal nummerisch und einmal string, analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ.
Dieses Mal wird die Spalte **KUNDEN_ID** mit unterschiedlichen [**nummerischen Datentypen**](Scripts/int) definiert.
Im zweiten Fall wird die Spalte **NAME** mit unterschiedlichen [**string Datentypen**](Scripts/string) definiert.

## Zielsetzung
Untersucht werden:
- Performance – Unterschied zwischen unterschiedlichen Datentypen (nummerisch und string) bei unterschiedlichem Befüllungsgrad
- Unterschiedliche Abfragen (group by, count, range comparison etc.) auf den beiden Tabellen
- Für string werden auch update durchgeführt und verglichen

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