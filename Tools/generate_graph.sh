#!/bin/bash

# Parse arguments
OUTPUT_DIR="$1"

# File Paths
PYTHON_PATH="/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Tools/Python"
OUTPUT_FILE="$OUTPUT_DIR/sysbench_output.csv"
OUTPUT_FILE_INOFFICIAL="$OUTPUT_DIR/sysbench_output_inofficial.csv"
STATISTICS_OUTPUT_FILE="$OUTPUT_DIR/statistics.csv"
STATISTICS_OUTPUT_FILE_INOFFICIAL="$OUTPUT_DIR/statistics_inofficial.csv"

# Statistics csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$STATISTICS_OUTPUT_FILE_INOFFICIAL" "$STATISTICS_OUTPUT_FILE" --insert_columns "Total Time"
echo "Combined CSV file created at $STATISTICS_OUTPUT_FILE"

# Outputfile csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$OUTPUT_FILE_INOFFICIAL" "$OUTPUT_FILE" --select_columns "Time (s),Threads"
echo "Combined CSV file created at $OUTPUT_FILE"

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 "$PYTHON_PATH/generatePlot.py" "$OUTPUT_FILE" "$STATISTICS_OUTPUT_FILE"