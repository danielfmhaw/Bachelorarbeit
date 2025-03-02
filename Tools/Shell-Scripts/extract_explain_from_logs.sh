#!/bin/bash
# ./extract_explain_from_logs.sh /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Index/B_Tree/Output/b-tree-query-differences combined_index

# Überprüfen, ob Outputordner und Index-Name übergeben wurden
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Bitte geben Sie den Outputordner und den Indexnamen an."
    echo "Beispiel: ./add_index_column.sh /path/to/logs index_name"
    exit 1
fi

# Definitionen
base_folder="$1"
index_name="$2"
log_folder="$base_folder/logs"
result_file="$base_folder/count_results.csv"
explain_file="$base_folder/count_results_explain.csv"

temp_file=$(mktemp)
head -n 1 "$result_file" | sed 's/$/,Index/' > "$temp_file"

# Jede Zeile nach dem Header durchgehen
tail -n +2 "$result_file" | while IFS=, read -r logfile count_value; do
    file_path=$(find "$log_folder" -type f -name "$logfile.log" 2>/dev/null)
    index_used="nein"
    if [[ -n "$file_path" ]]; then
        explain_line=$(awk '/EXPLAIN/ {getline; print $0}' "$file_path")
        index_used=$( [[ "$explain_line" == *"$index_name"* ]] && echo "ja" || echo "nein" )
    fi
    echo "$logfile,$count_value,$index_used" >> "$temp_file"
done

mv "$temp_file" "$explain_file"
echo "Das Script wurde ausgeführt. Die Datei '$explain_file' wurde erstellt."