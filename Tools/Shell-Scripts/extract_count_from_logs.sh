#!/bin/bash
# ./extract_count_from_logs.sh /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Index/B_Tree/Output/query_differences/logs/query_differences /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Latex/Arbeit/PNGs/Script/Index/B_Tree/b-tree-query-differences combined_index
# ./extract_count_from_logs.sh /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Index/Hash/Output/logs/query_differences /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Latex/Arbeit/PNGs/Script/Index/Hash/hash-query-differences combined_index

# Überprüfen, ob Quellordner, Zielordner und index_name übergeben wurden
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Bitte geben Sie den Quellordner (logs), den Zielordner und den Indexnamen an."
    echo "Beispiel: ./extract_count_from_logs.sh /path/to/logs /path/to/output index_name"
    exit 1
fi
# Definitions
base_folder="$1"
target_folder="$2"
index_name="$3"
output_file="$target_folder/count_results.csv"
temp_file="$target_folder/count_results_tmp.csv"
mkdir -p "$target_folder"

# Temporäre Datei zum Sammeln der Daten (ohne Header)
echo "" > "$temp_file"

# Logfiles durchgehen und Count-Werte extrahieren
for file in "$base_folder"/*.log; do
    filename=$(basename "$file" .log)
    if [ -f "$file" ] && [[ "$filename" == *select* ]]; then
        # Extrahiere den COUNT-Wert
        count_value=$(awk '/COUNT\(\*\)/ {getline; print $0}' "$file")

        # Prüfe, ob nach EXPLAIN das index_name vorkommt
        explain_line=$(awk '/EXPLAIN/ {getline; print $0}' "$file")
        index_used=$( [[ "$explain_line" == *"$index_name"* ]] && echo "ja" || echo "nein" )

        echo "$filename,$count_value,$index_used" >> "$temp_file"
    fi
done


# Sortieren nach der zweiten Spalte (numerisch) und in die finale CSV-Datei schreiben
echo "LogFile,CountValue,Index" > "$output_file"
sort -t, -k2,2n "$temp_file" >> "$output_file"
rm "$temp_file"

echo "CSV file created: $output_file"
