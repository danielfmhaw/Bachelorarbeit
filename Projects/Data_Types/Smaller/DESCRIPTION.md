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

## Durchführung: Ausführung des Benchmarks
Führe die folgenden Scripts aus, um die Benchmarks mit den korrekten Pfaden und Parametern zu starten.

### Code für Number Größenvergleich:
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Data_Types/Smaller/Output" \
  -var '{"datatyp":["smallint_13","smallint_16","mediumint_24","int_32","bigint_64","decimal_65"]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Data_Types/Smaller/Scripts/int": {
      "vars": "datatyp"
    }
  }'
```

### Code für String Größenvergleich:
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Data_Types/Smaller/Output" \
  -var '{"typ":["char_4","char_64","varchar_4","varchar_64"],"num_rows":[250]}' \
  -scripts '{
    "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Data_Types/Smaller/Scripts/string": {
      "vars": "typ,num_rows"
    }
  }'
```

### Code für das Aktualisierung von String - Typen:
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
-out "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Data_Types/Smaller/Output" \
-var '{"typ":["char_255","varchar_255"],"length":[56,240],"num_rows":[250]}' \
-scripts '{
  "/Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Data_Types/Smaller/Scripts/string": {
      "vars": "typ,length,num_rows",
      "stats_select_columns": "Total Time (s),Write (noq)",
      "stats_insert_columns": "",
      "runtime_select_columns": "Time (s),Threads,Writes",
      "runtime_insert_columns": ""
    }
  }'
```

### Nur Graphen erstellen für den Vergleich von numerischen- und Zeichenketten-Typen (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Data_Types/Smaller/Output
```
