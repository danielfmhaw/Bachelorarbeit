#!/bin/bash

# File Paths
GENERATE_PLOT_SCRIPT="/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Tools/Pandas/generateplot.py"
OUTPUT_DIR="output"
OUTPUT_FILE="$OUTPUT_DIR/sysbench_output.csv"
OUTPUT_FILE_INOFFICIAL="$OUTPUT_DIR/sysbench_output_inofficial.csv"
STATISTICS_OUTPUT_FILE="$OUTPUT_DIR/statistics.csv"

# Lua script directories for int_queries and varchar_queries
SCRIPT_PATHS=(
  "scripts/int_queries"
  "scripts/varchar_queries"
)

# Connection parameters
DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_USER="root"
DB_PASS="password"
DB_NAME="sbtest"

# Sysbench configuration
TIME=32
THREADS=8
EVENTS=0
REPORT_INTERVAL=4

# Ensure output directories exist
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Prepare CSV headers
echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs" > "$OUTPUT_FILE_INOFFICIAL"
echo "Script,Read,Write,Other,Total,Transactions,Queries,Ignored Errors,Reconnects,Total Time,Total Events,Latency Min,Latency Avg,Latency Max,Latency 95th Percentile,Latency Sum" > "$STATISTICS_OUTPUT_FILE"

# Helper function to run sysbench with specified Lua script and mode
run_sysbench() {
  local LUA_SCRIPT_PATH="$1"
  local MODE="$2"
  local LOG_FILE="$3"

  sysbench \
    --db-driver=mysql \
    --mysql-host="$DB_HOST" \
    --mysql-port="$DB_PORT" \
    --mysql-user="$DB_USER" \
    --mysql-password="$DB_PASS" \
    --mysql-db="$DB_NAME" \
    --time=$TIME \
    --threads=$THREADS \
    --events=$EVENTS \
    --report-interval=$REPORT_INTERVAL \
    "$LUA_SCRIPT_PATH" "$MODE" >> "$LOG_FILE" 2>&1

  return $?
}

# Function to extract and save run data
extract_run_data() {
  local RAW_RESULTS_FILE="$1"
  local SCRIPT_NAME="$2"

  grep '^\[ ' "$RAW_RESULTS_FILE" | while read -r line; do
    time=$(echo "$line" | awk '{print $2}' | sed 's/s//')
    threads=$(echo "$line" | awk -F 'thds: ' '{print $2}' | awk '{print $1}')
    tps=$(echo "$line" | awk -F 'tps: ' '{print $2}' | awk '{print $1}')
    qps=$(echo "$line" | awk -F 'qps: ' '{print $2}' | awk '{print $1}')
    read_write_other=$(echo "$line" | sed -E 's/.*\(r\/w\/o: ([0-9.]+)\/([0-9.]+)\/([0-9.]+)\).*/\1,\2,\3/')
    reads=$(echo "$read_write_other" | cut -d',' -f1)
    writes=$(echo "$read_write_other" | cut -d',' -f2)
    other=$(echo "$read_write_other" | cut -d',' -f3)
    latency=$(echo "$line" | awk -F 'lat \\(ms,95%\\): ' '{print $2}' | awk '{print $1}')
    err_per_sec=$(echo "$line" | awk -F 'err/s: ' '{print $2}' | awk '{print $1}')
    reconn_per_sec=$(echo "$line" | awk -F 'reconn/s: ' '{print $2}' | awk '{print $1}')

    echo "$SCRIPT_NAME,$time,$threads,$tps,$qps,$reads,$writes,$other,$latency,$err_per_sec,$reconn_per_sec" >> "$OUTPUT_FILE_INOFFICIAL"
  done
}

run_benchmark() {
  local SCRIPT_PATH="$1"
  local MODE="$2"
  local OUTPUT_FILE="$3"
  local SCRIPT_NAME="$4"

  run_sysbench "$SCRIPT_PATH" "$MODE" "$OUTPUT_FILE"
  if [ $? -ne 0 ]; then
    echo "Benchmark failed for script $SCRIPT_PATH. Exiting."
    exit 1
  fi

  echo "Benchmark complete for $SCRIPT_PATH"

  # Only extract data if the mode is "run"
  if [ "$MODE" == "run" ]; then
    extract_run_data "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
    extract_statistics "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
    echo "Results for $SCRIPT saved to $OUTPUT_FILE_INOFFICIAL and $STATISTICS_OUTPUT_FILE"
  fi
}

# Function to extract statistics from sysbench results
extract_statistics() {
  local RAW_RESULTS_FILE="$1"
  local SCRIPT_NAME="$2"

  # Extract SQL statistics and append to statistics.csv
  read=$(awk '/read:/ {print $2}' "$RAW_RESULTS_FILE")
  write=$(awk '/write:/ {print $2}' "$RAW_RESULTS_FILE")
  other=$(awk '/other:/ {print $2}' "$RAW_RESULTS_FILE")
  total=$(awk '/total:/ {print $2}' "$RAW_RESULTS_FILE")
  transactions=$(awk '/transactions:/ {print $2}' "$RAW_RESULTS_FILE")
  queries=$(awk '/queries:/ {print $2}' "$RAW_RESULTS_FILE")
  ignored_errors=$(awk '/ignored errors:/ {print $3}' "$RAW_RESULTS_FILE")
  reconnects=$(awk '/reconnects:/ {print $2}' "$RAW_RESULTS_FILE")
  total_time=$(awk '/total time:/ {print $3}' "$RAW_RESULTS_FILE")
  total_events=$(awk '/total number of events:/ {print $5}' "$RAW_RESULTS_FILE")
  latency_min=$(awk '/min:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_avg=$(awk '/avg:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_max=$(awk '/max:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_95th=$(awk '/95th percentile:/ {print $3}' "$RAW_RESULTS_FILE")
  latency_sum=$(awk '/sum:/ {print $2}' "$RAW_RESULTS_FILE")

  # Append the extracted data to the statistics output file
  echo "$SCRIPT_NAME,$read,$write,$other,$total,$transactions,$queries,$ignored_errors,$reconnects,$total_time,$total_events,$latency_min,$latency_avg,$latency_max,$latency_95th,$latency_sum" >> "$STATISTICS_OUTPUT_FILE"
}

# Main benchmark loop
for QUERY_PATH in "${SCRIPT_PATHS[@]}"; do
  MAIN_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH").lua"
  INSERT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_insert.lua"
  SELECT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_select.lua"
  LOG_DIR="$OUTPUT_DIR/logs/$(basename "$QUERY_PATH")"

  # Specific actions for varchar_queries
  if [[ "$QUERY_PATH" == "scripts/varchar_queries" ]]; then
    for LENGTH in 1 64; do
      export VARCHAR_LENGTH=$((LENGTH - 1))

      LOG_DIR_LENGTH="$LOG_DIR/length_$LENGTH"
      mkdir -p "$LOG_DIR_LENGTH"

      echo "Preparing database for $MAIN_SCRIPT with LENGTH $LENGTH..."
      RAW_RESULTS_FILE="${LOG_DIR_LENGTH}/$(basename "$QUERY_PATH")_${LENGTH}_prepare.log"
      run_benchmark "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE"

      # Run INSERT and SELECT benchmarks
      for SCRIPT in "$INSERT_SCRIPT" "$SELECT_SCRIPT"; do
        SCRIPT_NAME="${QUERY_PATH##*/}_${LENGTH}_$(basename "$SCRIPT" .lua | sed "s/^${QUERY_PATH##*/}_//")"
        RAW_RESULTS_FILE="$LOG_DIR_LENGTH/${SCRIPT_NAME}.log"
        run_benchmark "$SCRIPT" "run" "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
      done

      RAW_RESULTS_FILE="${LOG_DIR_LENGTH}/length_${LENGTH}_cleanup.log"
      run_benchmark "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
    done
  else
    # Process int_queries normally
    mkdir -p "$LOG_DIR"
    echo "Preparing database for $MAIN_SCRIPT..."
    RAW_RESULTS_FILE="$LOG_DIR/$(basename "$QUERY_PATH")_prepare.log"
    run_benchmark "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE"

    # Run INSERT and SELECT benchmarks
    for SCRIPT in "$INSERT_SCRIPT" "$SELECT_SCRIPT"; do
      SCRIPT_NAME=$(basename "$SCRIPT" .lua)
      RAW_RESULTS_FILE="$LOG_DIR/${SCRIPT_NAME}.log"
      run_benchmark "$SCRIPT" "run" "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
    done

    # Cleanup phase
    echo "Cleaning up database for $MAIN_SCRIPT..."
    RAW_RESULTS_FILE="$LOG_DIR/$(basename "$QUERY_PATH")_cleanup.log"
    run_benchmark "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
  fi
done

# Prepare CSV header for the output file
echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs,Inserts" > "$OUTPUT_FILE"

# Read the input file (skip the header)
tail -n +2 "$OUTPUT_FILE_INOFFICIAL" | while IFS=, read -r SCRIPT TIME THREADS TPS QPS READS WRITES OTHER LATENCY ERRPS RECONNPS; do
    # Determine the base script name by removing _insert or _select suffix
    BASE_SCRIPT=$(echo "$SCRIPT" | sed -E 's/_(insert|select)$//')

    # Check if it's an insert script row, in which case we try to find matching select
    if [[ "$SCRIPT" == *_insert ]]; then
        # Read corresponding select row with the same base script and time
        MATCHING_SELECT=$(grep "${BASE_SCRIPT}_select,$TIME," "$OUTPUT_FILE_INOFFICIAL")

        if [[ -n "$MATCHING_SELECT" ]]; then
            # Extract values from matching select row
            IFS=, read -r _ _ _ TPS_SEL QPS_SEL READS_SEL WRITES_SEL OTHER_SEL LATENCY_SEL ERRPS_SEL RECONNPS_SEL <<< "$MATCHING_SELECT"

            # Sum up values from insert and select rows
            COMBINED_TPS=$(echo "$TPS + $TPS_SEL" | bc)
            COMBINED_QPS=$(echo "$QPS + $QPS_SEL" | bc)
            COMBINED_READS=$(echo "$READS + $READS_SEL" | bc)
            COMBINED_WRITES=$(echo "$WRITES + $WRITES_SEL" | bc)
            COMBINED_OTHER=$(echo "$OTHER + $OTHER_SEL" | bc)
            COMBINED_LATENCY=$(echo "$LATENCY + $LATENCY_SEL" | bc)
            COMBINED_ERRPS=$(echo "$ERRPS + $ERRPS_SEL" | bc)
            COMBINED_RECONNPS=$(echo "$RECONNPS + $RECONNPS_SEL" | bc)
            COMBINED_WRITEONLY=$(echo "$QPS" | bc)

            # Write combined row to output CSV
            echo "${BASE_SCRIPT},$TIME,$THREADS,$COMBINED_TPS,$COMBINED_QPS,$COMBINED_READS,$COMBINED_WRITES,$COMBINED_OTHER,$COMBINED_LATENCY,$COMBINED_ERRPS,$COMBINED_RECONNPS,$COMBINED_WRITEONLY" >> "$OUTPUT_FILE"
        fi
    fi
done

echo "Combined CSV file created at $OUTPUT_FILE"

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 "$GENERATE_PLOT_SCRIPT" "$OUTPUT_FILE"

# Check if the plot generation was successful
if [ $? -eq 0 ]; then
    echo "Plots generated successfully."
else
    echo "Plot generation failed."
    exit 1
fi