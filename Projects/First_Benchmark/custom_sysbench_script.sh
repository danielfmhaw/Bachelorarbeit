#!/bin/bash

# File Paths
OUTPUT_FILE="output/sysbench_output.csv"
OUTPUT_DIR="output/logs"
GENERATE_PLOT_SCRIPT="/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Tools/Pandas/generateplot.py"

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
TIME=60
THREADS=8
EVENTS=0
REPORT_INTERVAL=5

# Ensure output directories exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Prepare CSV header
echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs" > "$OUTPUT_FILE"

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

# Loop through each query path
for QUERY_PATH in "${SCRIPT_PATHS[@]}"; do
  MAIN_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH").lua"
  INSERT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_insert.lua"
  SELECT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_select.lua"

  # Prepare phase
  RAW_RESULTS_FILE="$OUTPUT_DIR/$(basename "$QUERY_PATH")_prepare.log"
  echo "Preparing database for $MAIN_SCRIPT..."
  run_sysbench "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE"
  if [ $? -ne 0 ]; then
    echo "Database preparation failed for $MAIN_SCRIPT. Exiting."
    exit 1
  fi
  echo "Database prepared for $MAIN_SCRIPT."

  # Run benchmarks for INSERT and SELECT
  for SCRIPT in "$INSERT_SCRIPT" "$SELECT_SCRIPT"; do
    SCRIPT_NAME=$(basename "$SCRIPT" .lua)
    RAW_RESULTS_FILE="$OUTPUT_DIR/${SCRIPT_NAME}_sysbench.log"

    echo "Running benchmark for $SCRIPT..."
    run_sysbench "$SCRIPT" "run" "$RAW_RESULTS_FILE"
    if [ $? -ne 0 ]; then
      echo "Benchmark failed for script $SCRIPT. Exiting."
      exit 1
    fi
    echo "Benchmark complete for $SCRIPT."

    # Extract data and format it as CSV
    grep '^\[ ' "$RAW_RESULTS_FILE" | while read -r line; do
      time=$(echo "$line" | awk '{print $2}' | sed 's/s//')
      threads=$(echo "$line" | awk -F 'thds: ' '{print $2}' | awk '{print $1}')
      tps=$(echo "$line" | awk -F 'tps: ' '{print $2}' | awk '{print $1}')
      qps=$(echo "$line" | awk -F 'qps: ' '{print $2}' | awk '{print $1}')

      # Split read, write, and other counts
      read_write_other=$(echo "$line" | sed -E 's/.*\(r\/w\/o: ([0-9.]+)\/([0-9.]+)\/([0-9.]+)\).*/\1,\2,\3/')
      reads=$(echo "$read_write_other" | cut -d',' -f1)
      writes=$(echo "$read_write_other" | cut -d',' -f2)
      other=$(echo "$read_write_other" | cut -d',' -f3)

      latency=$(echo "$line" | awk -F 'lat \\(ms,95%\\): ' '{print $2}' | awk '{print $1}')
      err_per_sec=$(echo "$line" | awk -F 'err/s: ' '{print $2}' | awk '{print $1}')
      reconn_per_sec=$(echo "$line" | awk -F 'reconn/s: ' '{print $2}' | awk '{print $1}')

      # Append to CSV file with script identifier
      echo "$SCRIPT_NAME,$time,$threads,$tps,$qps,$reads,$writes,$other,$latency,$err_per_sec,$reconn_per_sec" >> "$OUTPUT_FILE"
    done
    echo "Results for $SCRIPT saved to $OUTPUT_FILE."
  done

  # Cleanup phase
  RAW_RESULTS_FILE="$OUTPUT_DIR/$(basename "$QUERY_PATH")_cleanup.log"
  echo "Cleaning up database for $MAIN_SCRIPT..."
  run_sysbench "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
  if [ $? -ne 0 ]; then
    echo "Database cleanup failed for $MAIN_SCRIPT."
    exit 1
  fi
  echo "Database cleanup complete for $MAIN_SCRIPT."
done

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