#!/bin/bash
# ./calculate_difference_factor.sh /Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/B_Tree/Output/b-tree-query-differences/count_results_explain.csv /Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/B_Tree/Output/b-tree-query-differences/sysbench_statistics.csv /Users/danielmendes/Desktop/Bachelorarbeit/Projekte_BA/Bachelorarbeit_Repo/Projects/Index/B_Tree/Output/b-tree-query-differences-no-index/sysbench_statistics.csv

# Überprüfen, ob die notwendigen Argumente (CSV-Dateien) übergeben wurden
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Bitte geben Sie die drei CSV-Dateien an."
    echo "Beispiel: ./calculate_difference_factor.sh result.csv zaehler.csv nenner.csv"
    exit 1
fi

# Definitionen
explain_file="$1"
zaehler_file="$2"
nenner_file="$3"
factor_file="$(dirname "$explain_file")/count_results_index_factor.csv"

temp_file=$(mktemp)
head -n 1 "$explain_file" | sed 's/$/,Factor/' > "$temp_file"

# Gehe durch jede Zeile der result-Datei, ab der dritten Zeile
tail -n +2 "$explain_file" | while IFS=, read -r log_file count_value index; do
    script_name=$(echo "$log_file" | sed 's/.*_select_//')
    zaehler_read_value=$(awk -F',' -v script="$script_name" '$1 ~ script {print $2}' "$zaehler_file")
    nenner_read_value=$(awk -F',' -v script="$script_name" '$1 ~ script {print $2}' "$nenner_file")

    # Überprüfe, ob der Nenner gültig ist
    if [[ -n "$zaehler_read_value" && -n "$nenner_read_value" && $(echo "$nenner_read_value != 0.00" | bc) -eq 1 ]]; then
        result=$(printf "%0.2f" "$(echo "scale=2; $zaehler_read_value / $nenner_read_value" | bc)")
    else
        result="NaN"
    fi
    echo "$log_file,$count_value,$index,$result" >> "$temp_file"
done

mv "$temp_file" "$factor_file"
echo "Das Script wurde ausgeführt. Die Datei '$factor_file' wurde erstellt."
