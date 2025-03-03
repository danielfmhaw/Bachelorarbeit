#!/bin/bash

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
          custom_name=$(echo "$line" | sed -n 's/.*CustomName:\([^;]*\).*/\1/p' | tr '[:upper:]' '[:lower:]')
          count_value=$(echo "$line" | sed -n 's/.*CountValue:\([0-9]*\).*/\1/p')
          combined_value="$filename$( [ "$custom_name" = "nil" ] && echo "" || echo "_$custom_name" ),$count_value"
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
