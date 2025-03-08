#!/bin/bash
# ./extract_cpu_usage_from_logs.sh /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Projects/Replication/Output

# Überprüfen, ob Outputordner übergeben wurde
[ -z "$1" ] && { echo "Bitte geben Sie einen Ordner an."; exit 1; }

# Definitionen
base_folder="$1"
log_folder="$base_folder/logs"
result_file="$base_folder/average_results_cpu_usage.csv"
temp_file=$(mktemp)

# Alle Logfiles (auch in Unterordnern) durchsuchen
find "$log_folder" -type f -name "*.log" | while read -r file; do
  filename=$(basename "$file" .log)

  if [[ "$filename" == *_select* ]]; then
    total_cpu_usage=0
    count_cpu=0

    while IFS= read -r line; do
      # Nach der Zeile mit "read:" suchen (nur einmal)
      read_value=$(awk '/read:/ {print $2}' "$file")

      # Nach der Zeile mit "CPU-Usage:" suchen
      if [[ "$line" =~ CPU-Usage:([0-9.]+)% ]]; then
        cpu_usage="${BASH_REMATCH[1]}"
        total_cpu_usage=$(echo "$total_cpu_usage + $cpu_usage" | bc)
        count_cpu=$((count_cpu + 1))
      fi
    done < "$file"

    if [ "$count_cpu" -gt 0 ]; then
      avg_cpu_usage=$(echo "scale=2; $total_cpu_usage / $count_cpu" | bc)
      echo "$filename,$avg_cpu_usage,$read_value" >> "$temp_file"
    fi
  fi
done

# Aufsteigend nach CPU Usage sortieren
echo "LogFile,Average CPU Usage,Read Value" > "$result_file"
sort -t, -k3,3nr "$temp_file" >> "$result_file"
rm "$temp_file"
echo "Durchschnittsergebnisse CSV erstellt unter $result_file"
