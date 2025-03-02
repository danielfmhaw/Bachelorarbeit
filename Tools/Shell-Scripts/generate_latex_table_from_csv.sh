#!/bin/bash

# Überprüfen, ob eine Eingabedatei übergeben wurde
[ -z "$1" ] && { echo "Bitte geben Sie den Pfad zur CSV-Datei an."; exit 1; }

input_file="$1"

header=$(head -n 1 "$input_file")
IFS=',' read -r -a columns <<< "$header"

# Tabellenformat vorbereiten
table_format=$(printf "|%0.sl" $(seq 1 ${#columns[@]}) | sed 's/.*/&|/')

# LaTeX-Header für die Tabelle vorbereiten
latex_header=""
for column in "${columns[@]}"; do
    latex_header+="\\textbf{$column} & "
done
latex_header=${latex_header% & }

echo "\\vspace{-5pt}"
echo "\\begin{table}[H]"
echo "    \\centering"
echo "    \\scriptsize"
echo "    \\begin{tabular}{$table_format}"
echo "        \\hline"
echo "        $latex_header \\\\"
echo "        \\hline"

tail -n +2 "$input_file" | while IFS=, read -r -a fields; do
    processed_fields=()
    for field in "${fields[@]}"; do
        processed_field=$(echo "$field" | sed 's/_/\\_/g')
        processed_fields+=("$processed_field")
    done
    echo "        $(IFS=\& ; echo "${processed_fields[*]}") \\\\" | sed 's/&/ \& /g'
done

echo "        \\hline"
echo "    \\end{tabular}"
echo "    \\vspace{3pt}"
echo "    \\caption{ToDo: Überarbeiten}"
echo "    \\label{tab:todo-ueberarbeiten}"
echo "\\end{table}"
echo "\\vspace{-25pt}"