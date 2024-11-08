#!/bin/bash

# File Paths
GENERATE_PLOT_SCRIPT="/Users/danielmendes/Desktop/Bachelorarbeit/Ausarbeitung/Tools/Pandas/generateplot.py"
OUTPUT_DIR="output"
OUTPUT_FILE="output/sysbench_output.csv"
RAW_RESULTS_FILE="output/sysbench.log"
GNUPLOT_SCRIPT="plot_sysbench.gp"

# Connection parameters
DB_HOST="localhost"
DB_USER="root"
DB_PASS="password"
DB_NAME="sbtest"
TABLES=10
TABLE_SIZE=10000
DURATION=10

# Ensure output directories exist
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Preparing the database..."
sysbench oltp_read_write \
  --db-driver=mysql \
  --mysql-host=$DB_HOST \
  --mysql-user=$DB_USER \
  --mysql-password=$DB_PASS \
  --mysql-db=$DB_NAME \
  --tables=$TABLES \
  --table-size=$TABLE_SIZE \
  prepare > $RAW_RESULTS_FILE 2>&1

echo "Database prepared."

echo "Running benchmark..."
sysbench oltp_read_write \
  --db-driver=mysql \
  --mysql-host=$DB_HOST \
  --mysql-user=$DB_USER \
  --mysql-password=$DB_PASS \
  --mysql-db=$DB_NAME \
  --tables=$TABLES \
  --table-size=$TABLE_SIZE \
  --time=$DURATION \
  --threads=1 \
  --report-interval=1 \
  run >> $RAW_RESULTS_FILE 2>&1

echo "Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs" > "$OUTPUT_FILE"

# Extract the relevant lines and format as CSV
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

    echo "$time,$threads,$tps,$qps,$reads,$writes,$other,$latency,$err_per_sec,$reconn_per_sec" >> "$OUTPUT_FILE"
done

echo "Benchmark complete. Results saved to $OUTPUT_FILE."

echo "Cleaning up..."

sysbench oltp_read_write \
  --db-driver=mysql \
  --mysql-host=$DB_HOST \
  --mysql-user=$DB_USER \
  --mysql-password=$DB_PASS \
  --mysql-db=$DB_NAME \
  --tables=$TABLES \
  cleanup >> $RAW_RESULTS_FILE 2>&1

echo "Database cleanup complete."

# Generate plot with gnuplot
rm -rf "$OUTPUT_DIR/gnuplot"
mkdir -p "$OUTPUT_DIR/gnuplot"
echo "Generating plot with gnuplot..."
gnuplot $GNUPLOT_SCRIPT

# Generate plot with pandas und verschiebe die Objekte in Pandas
echo "Generating plots with pandas..."
python3 "$GENERATE_PLOT_SCRIPT" "$OUTPUT_FILE"
SOURCE_DIR="output/detailed_pngs"
DEST_DIR="output/pandas"
FILE_TO_MOVE="output/output_final.png"
mkdir -p "$DEST_DIR"
mv "$SOURCE_DIR"/* "$DEST_DIR"
mv "$FILE_TO_MOVE" "$DEST_DIR/Summary.png"
rm -rf "$SOURCE_DIR"

echo "Plots generated."