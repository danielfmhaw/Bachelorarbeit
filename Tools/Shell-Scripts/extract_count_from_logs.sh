#!/bin/bash
# ./extract_count_from_logs.sh /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Index/B_Tree/Output/b-tree-query-differences

# Überprüfen, ob Outputordner übergeben wurde
[ -z "$1" ] && { echo "Bitte geben Sie einen Ordner an."; exit 1; }

# Definitionen
base_folder="$1"
log_folder="$base_folder/logs"
result_file="$base_folder/count_results.csv"
temp_file=$(mktemp)

# Alle Logfiles (auch in Unterordnern) durchsuchen und Count-Werte extrahieren
find "$log_folder" -type f -name "*.log" | while read -r file; do
  filename=$(basename "$file" .log)
    if [[ "$filename" == *_select* ]]; then
      while IFS= read -r line; do
        if [[ "$line" == "Executed Query:"* && "$line" == *"COUNT(*)"* ]]; then
          read -r custom_name_line
          if [[ "$custom_name_line" == CUSTOM_NAME:* ]]; then
              query_name=$(echo "$custom_name_line" | sed 's/CUSTOM_NAME://g' | tr '[:upper:]' '[:lower:]' | xargs)
              read -r count_value
              combined_value="${filename}_${query_name},${count_value}"
          else
              combined_value="$filename,$custom_name_line"
          fi
          IFS=',' read -r query_name count_value <<< "$combined_value"
          if [[ "$count_value" =~ ^[0-9]+$ ]] && ! awk -F, -v k="$query_name" '$1 == k {found=1; exit} END {exit !found}' "$temp_file"; then
              echo "$query_name,$count_value" >> "$temp_file"
          fi
        fi
      done < "$file"
  fi
done

# Aufsteigend nach CountValue sortieren
echo "LogFile,CountValue" > "$result_file"
sort -t, -k2,2n "$temp_file" >> "$result_file"
rm "$temp_file"
echo "Result CSV created at $result_file"
