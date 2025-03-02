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
    found_count=false
    while IFS= read -r line; do
      if [[ "$line" == "Executed Query:"* && "$line" == *"COUNT(*)"* ]]; then
        read -r custom_name_line
        query_name=""
        count_value=""
        if [[ "$custom_name_line" == CUSTOM_NAME:* ]]; then
            query_name=$(echo "$custom_name_line" | sed 's/CUSTOM_NAME://g' | tr '[:upper:]' '[:lower:]' | xargs)
            while read -r count_value; do
              [[ "$count_value" == COUNT:* ]] && break
            done
            query_name="${filename}_${query_name}"
            count_value=${count_value#COUNT:}
        elif [[ "$found_count" == false ]]; then
            if [[ "$custom_name_line" != COUNT:* ]]; then
              while read -r custom_name_line; do
                 [[ "$custom_name_line" == COUNT:* ]] && break
              done
            fi
            query_name="${filename}"
            count_value=${custom_name_line#COUNT:}
            found_count=true
        fi

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
