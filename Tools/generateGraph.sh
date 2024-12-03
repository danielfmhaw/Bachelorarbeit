#!/bin/bash

# Parse arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <output_dir> [custom_lengths] <query_info> ..."
    echo "Example 1: $0 output \"1,64\" \"dir_path/int_queries:false\" \"dir_path/varchar_queries:true\""
    echo "Example 2: $0 output \"dir_path/int_queries\" \"dir_path/varchar_queries\""
fi

OUTPUT_DIR="$1"
CUSTOM_LENGTHS=""
QUERY_INFO=("${@:2}")

if [[ ! "${QUERY_INFO[0]}" == *:* ]]; then
    CUSTOM_LENGTHS="${QUERY_INFO[0]}"
    QUERY_INFO=("${@:3}")
fi

# Process QUERY_INFO to detect if lengths are required
NEEDS_CUSTOM_LENGTHS=false
for INFO in "${QUERY_INFO[@]}"; do
    if [[ "$INFO" != *:* ]]; then
        INFO="${INFO}:false"
    fi
    if [[ "$INFO" == *":true"* ]]; then
        NEEDS_CUSTOM_LENGTHS=true
    fi
done

if $NEEDS_CUSTOM_LENGTHS && [ -z "$CUSTOM_LENGTHS" ]; then
    echo "Error: CUSTOM_LENGTHS is required because at least one QUERY_INFO has :true"
    exit 1
fi

# File Paths
PYHTON_PATH="/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Tools/Python"
OUTPUT_FILE="$OUTPUT_DIR/sysbench_output.csv"

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 "$PYHTON_PATH/generatePlot.py" "$OUTPUT_FILE"