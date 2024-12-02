•	Performance – Unterschied mit unterschiedlichen Zeilenanzahl
•	Veranschaulichung der Performanceunterschiede, je nach Sortierung des Index usw.


Eine riesige Tabelle erstellen mit unterschiedlicher Anzahl an Zeilen (4 unterschiedliche)

Ein Index aus Last_Name, First_Name and B_Day und vor und nachteile suchen dafür


### Code - Beispiel für High Count Vergleich:

```bash
cd ../../..
cd Tools
./custom_sysbench_script.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Output/count_row_changes/high_counts \
  "5000,50000" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/count_row_changes/with_index:true" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/count_row_changes/without_index:true"
```

### Code - Beispiel für Low Count Vergleich:
```bash
cd ../../..
cd Tools
./custom_sysbench_script.sh \
  /Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Output/count_row_changes/low_counts \
  "10,50" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/count_row_changes/with_index:true" \
  "/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Projects/Index/B_Tree/Scripts/count_row_changes/without_index:true"
```