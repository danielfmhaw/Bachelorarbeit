#!/bin/bash

# File Paths
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

echo "Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms,95%),Err/s,Reconn/s" > "$OUTPUT_FILE"

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

# Generate the Gnuplot graph
echo "Generating plot..."
gnuplot $GNUPLOT_SCRIPT
echo "Plot generated."

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