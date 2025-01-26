#!/bin/bash

ABS_PATH="/Users/danielmendes/Desktop/Bachelorarbeit/Repo"
GENERATE_PLOT_SCRIPT="${ABS_PATH}/Tools/Python/generatePlot.py"

# shellcheck disable=SC2046
eval $(jq -r --arg env "mysql" '.[$env] | to_entries | .[] | "export " + .key + "=" + (.value | @sh)' "$ABS_PATH/envs.json")
OUTPUT_DIR="output"
[[ "$1" == "-out" ]] && OUTPUT_DIR="$2" && shift 2

OUTPUT_FILE="$OUTPUT_DIR/sysbench_output.csv"
RAW_RESULTS_FILE="$OUTPUT_DIR/sysbench.log"
GNUPLOT_SCRIPT="plot_sysbench.gp"

# Benchmark Settings
TABLES=10
TABLE_SIZE=10000
DURATION=10

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to run sysbench with parameters
run_sysbench() {
  local MODE="$1"
  local EXTRA_ARGS="$2"
  local LOG_FILE="$3"

  sysbench oltp_read_write \
    --db-driver=mysql \
    --mysql-host="$DB_HOST" \
    --mysql-user="$DB_USER" \
    --mysql-password="$DB_PASS" \
    --mysql-db="$DB_NAME" \
    --tables="$TABLES" \
    --table-size="$TABLE_SIZE" \
    $EXTRA_ARGS \
    $MODE >> "$LOG_FILE" 2>&1

  return $?
}

echo "Preparing the database..."
run_sysbench "prepare" "" "$RAW_RESULTS_FILE"
echo "Database prepared."

echo "Running benchmark..."
run_sysbench "run" "--time=$DURATION --threads=1 --report-interval=1" "$RAW_RESULTS_FILE"
echo "Benchmark complete."

# Format the results into CSV
echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs" > "$OUTPUT_FILE"
grep '^\[ ' $RAW_RESULTS_FILE | while read -r line; do
    time=$(echo $line | awk '{print $2}' | sed 's/s//')
    threads=$(echo $line | awk -F 'thds: ' '{print $2}' | awk '{print $1}')
    tps=$(echo $line | awk -F 'tps: ' '{print $2}' | awk '{print $1}')
    qps=$(echo $line | awk -F 'qps: ' '{print $2}' | awk '{print $1}')
    read_write_other=$(echo $line | sed -E 's/.*\(r\/w\/o: ([0-9.]+)\/([0-9.]+)\/([0-9.]+)\).*/\1,\2,\3/')
    reads=$(echo $read_write_other | cut -d',' -f1)
    writes=$(echo $read_write_other | cut -d',' -f2)
    other=$(echo $read_write_other | cut -d',' -f3)
    latency=$(echo $line | awk -F 'lat \\(ms,95%\\): ' '{print $2}' | awk '{print $1}')
    err_per_sec=$(echo $line | awk -F 'err/s: ' '{print $2}' | awk '{print $1}')
    reconn_per_sec=$(echo $line | awk -F 'reconn/s: ' '{print $2}' | awk '{print $1}')

    echo "demo,$time,$threads,$tps,$qps,$reads,$writes,$other,$latency,$err_per_sec,$reconn_per_sec" >> "$OUTPUT_FILE"
done
echo "Results saved to $OUTPUT_FILE."

echo "Cleaning up..."
run_sysbench "cleanup" "" "$RAW_RESULTS_FILE"
echo "Database cleanup complete."

# Generate plot with gnuplot
rm -rf "$OUTPUT_DIR/gnuplot"
mkdir -p "$OUTPUT_DIR/gnuplot"
echo "Generating plot with gnuplot..."
gnuplot $GNUPLOT_SCRIPT
echo "Plots generated with gnuplot"

# Generate plot with pandas and move objects
echo "Generating plots with pandas..."
python3 "$GENERATE_PLOT_SCRIPT" "$OUTPUT_FILE"
SOURCE_DIR="output/pngs"
DEST_DIR="output/pandas"
FILE_TO_MOVE="output/pngs/script_comparison/demo.png"
mkdir -p "$DEST_DIR"
mv "$SOURCE_DIR/metric_comparison"/* "$DEST_DIR"
mv "$FILE_TO_MOVE" "$DEST_DIR/Summary.png"
rm -rf "$SOURCE_DIR"