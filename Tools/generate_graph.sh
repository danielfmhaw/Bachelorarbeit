#!/bin/bash

# Parse arguments
OUTPUT_DIR="$1"

# File Paths
PYTHON_PATH="/Users/danielmendes/Desktop/Bachelorarbeit/Repo/Tools/Python"
RUNTIME_FILE="$OUTPUT_DIR/sysbench_runtime.csv"
RUNTIME_FILE_TEMP="$OUTPUT_DIR/sysbench_runtime_temp.csv"
STATISTICS_FILE="$OUTPUT_DIR/sysbench_statistics.csv"
STATISTICS_FILE_TEMP="$OUTPUT_DIR/sysbench_statistics_temp.csv"

# Statistics csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$STATISTICS_FILE_TEMP" "$STATISTICS_FILE" --select_columns "Total Time"
echo "Combined CSV file created at $STATISTICS_FILE"

# Outputfile csv generated
python3 "$PYTHON_PATH/generateCombinedCSV.py" "$RUNTIME_FILE_TEMP" "$RUNTIME_FILE" --select_columns "Time (s),Threads"
echo "Combined CSV file created at $RUNTIME_FILE"

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 "$PYTHON_PATH/generatePlot.py" "$RUNTIME_FILE" "$STATISTICS_FILE"