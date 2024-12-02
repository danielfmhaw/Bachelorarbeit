# Index - Performance - Analyse

## Beschreibung

Es wird die **Performance vom B-Tree-Index** (Default Index in MySQL) analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ. 

## Zielsetzung
Untersucht werden:
- Performance – Unterschied mit **unterschiedlichen Zeilenanzahl**
- Veranschaulichung der Performanceunterschiede, **je nach Sortierung** des Index usw.


Eine riesige Tabelle erstellen mit unterschiedlicher Anzahl an Zeilen (4 unterschiedliche)

Nptizen
Ein Index aus Last_Name, First_Name and B_Day


### Code für High Count Vergleich:

```bash
cd ../../..
cd Tools
./custom_sysbench_script.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Output/count_row_changes/high_counts \
  "5000,50000" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/count_row_changes/with_index:true" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/count_row_changes/without_index:true"
```

### Code für Low Count Vergleich:
```bash
cd ../../..
cd Tools
./custom_sysbench_script.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Output/count_row_changes/low_counts \
  "10,50" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/count_row_changes/with_index:true" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/count_row_changes/without_index:true"
```

### Code unterschiedliche Select - Queries
```bash
cd ../../..
cd Tools
./custom_sysbench_script.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Output/query_differences \
 "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/query_differences:false" 
```