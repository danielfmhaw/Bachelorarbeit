#!/bin/bash

# File Paths
OUTPUT_FILE="output/sysbench_output.csv"
OUTPUT_DIR="output/logs"
LUA_SCRIPTS=("int_queries.lua" "varchar_queries.lua")

# Connection parameters
DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_USER="root"
DB_PASS="password"
DB_NAME="sbtest"

# Sysbench configuration
TIME=60
THREADS=4
EVENTS=0
POINT_SELECTS=10
REPORT_INTERVAL=1

# Ensure output directories exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Prepare CSV header
echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms,95%),Err/s,Reconn/s" > "$OUTPUT_FILE"

# Loop through each Lua script
for LUA_SCRIPT in "${LUA_SCRIPTS[@]}"; do
  SCRIPT_NAME=$(basename "$LUA_SCRIPT" .lua)
  RAW_RESULTS_FILE="$OUTPUT_DIR/${SCRIPT_NAME}_sysbench.log"

  # Prepare the database
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
    --point_selects=$POINT_SELECTS \
    --report-interval=$REPORT_INTERVAL \
    "$LUA_SCRIPT" prepare > "$RAW_RESULTS_FILE" 2>&1

  if [ $? -ne 0 ]; then
    echo "Database preparation failed for script $LUA_SCRIPT. Exiting."
    exit 1
  fi
  echo "Database prepared for $LUA_SCRIPT."

  # Run the benchmark
  echo "Running benchmark for $LUA_SCRIPT..."
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
    --point_selects=$POINT_SELECTS \
    --report-interval=$REPORT_INTERVAL \
    "$LUA_SCRIPT" run >> "$RAW_RESULTS_FILE" 2>&1

  if [ $? -ne 0 ]; then
    echo "Benchmark failed for script $LUA_SCRIPT. Exiting."
    exit 1
  fi
  echo "Benchmark complete for $LUA_SCRIPT."

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

  echo "Results for $LUA_SCRIPT saved to $OUTPUT_FILE."

  # Clean up the database
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
    --point_selects=$POINT_SELECTS \
    --report-interval=$REPORT_INTERVAL \
    "$LUA_SCRIPT" cleanup >> "$RAW_RESULTS_FILE" 2>&1

  if [ $? -ne 0 ]; then
    echo "Database cleanup failed for script $LUA_SCRIPT."
    exit 1
  fi
  echo "Database cleanup complete for $LUA_SCRIPT."
done

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 generateplot.py "$OUTPUT_FILE" QPS Reads Writes Other

# Check if the plot generation was successful
if [ $? -eq 0 ]; then
    echo "Plots generated successfully."
else
    echo "Plot generation failed."
    exit 1
fi