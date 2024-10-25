#!/bin/bash

# File Paths
OUTPUT_FILE="output/sysbench_output.csv"
RAW_RESULTS_FILE="output/sysbench.log"
GNUPLOT_SCRIPT="/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Tools/plot_sysbench.gp"
LUA_SCRIPT="custom_sysbench_script.lua"

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

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Prepare the database
echo "Preparing the database..."
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
  echo "Database preparation failed. Exiting."
  exit 1
fi
echo "Database prepared."

# Run the benchmark
echo "Running benchmark..."
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
  echo "Benchmark failed. Exiting."
  exit 1
fi
echo "Benchmark complete."

# Prepare CSV header
echo "Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms,95%),Err/s,Reconn/s" > "$OUTPUT_FILE"

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

    # Append to CSV file
    echo "$time,$threads,$tps,$qps,$reads,$writes,$other,$latency,$err_per_sec,$reconn_per_sec" >> "$OUTPUT_FILE"
done

echo "Results saved to $OUTPUT_FILE."

# Generate plot
if command -v gnuplot >/dev/null 2>&1; then
  echo "Generating plot..."
  gnuplot "$GNUPLOT_SCRIPT"
  echo "Plot generated."
else
  echo "Gnuplot not installed. Skipping plot generation."
fi

# Clean up the database
echo "Cleaning up..."
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
  echo "Database cleanup failed."
  exit 1
fi
echo "Database cleanup complete."