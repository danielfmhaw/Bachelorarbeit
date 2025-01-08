#!/bin/bash

# ./extract_needed_pngs.sh /Users/danielmendes/Desktop/Bachelorarbeit/Repo/Tools/combined-output

# Überprüfen, ob ein Ordner übergeben wurde
if [ -z "$1" ]; then
    echo "Bitte geben Sie einen Ordner an."
    exit 1
fi

# Zielordner
base_folder="$1"
target_folder="/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Latex/Arbeit/PNGs/Script"

# Funktion zum Verarbeiten der Unterordner
process_folder() {
    local folder="$1"

    if [ ! -d "$folder" ]; then
        return
    fi

    local stats_file
    stats_file=$(find "$folder" -maxdepth 1 -type f -name "statistics.png" 2>/dev/null)

    # Wenn "statistics.png" gefunden wird
    if [ -n "$stats_file" ]; then
        local stats_dir
        stats_dir=$(dirname "$stats_file")

        # Suchen nach "Writes.png" und "Reads.png" weiter unten im Verzeichnisbaum
        for file in "Writes.png" "Reads.png" "statistics.png"; do
            local src_file
            src_file=$(find "$folder" -type f -name "$file" 2>/dev/null)
            if [ -n "$src_file" ]; then
                # Move the files one folder above
                mv "$src_file" "$stats_dir/../"
            fi
        done

        # Delete the current folder after moving the files
        rmdir "$stats_dir" 2>/dev/null
    fi

    # Löschen aller anderen Dateien im Ordner und Unterordner
    find "$folder" -type f ! \( -name "statistics.png" -o -name "Writes.png" -o -name "Reads.png" \) -exec rm {} + 2>/dev/null

    # Löschen aller leeren Unterordner
    find "$folder" -type d -empty -delete 2>/dev/null
}

# Rekursives Durchgehen aller Unterordner
find "$base_folder" -type d | while read -r subfolder; do
    process_folder "$subfolder"
done

rm -rf "$target_folder"
mv "$base_folder" "$target_folder"
echo "Fertig!"