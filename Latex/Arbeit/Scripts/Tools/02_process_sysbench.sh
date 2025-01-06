# Define necessary variables
DB_HOST="127.0.0.1"
DB_USER="root"
DB_PASS="password"
DB_NAME="sbtest"
TABLES=10
TABLE_SIZE=10000
DURATION=10
RAW_RESULTS_FILE="output/sysbench.log"

SYSBENCH_OPTS="--db-driver=mysql --mysql-host=$DB_HOST --mysql-user=$DB_USER --mysql-password=$DB_PASS --mysql-db=$DB_NAME --tables=$TABLES --table-size=$TABLE_SIZE"

# Create output directory
rm -rf "output"
mkdir -p "output"

# Prepare the database
echo "Preparing the database...";
sysbench oltp_read_write $SYSBENCH_OPTS prepare >> "$RAW_RESULTS_FILE" 2>&1
echo "Database prepared."

# Run the benchmark
echo "Running benchmark...";
sysbench oltp_read_write $SYSBENCH_OPTS --time=$DURATION --threads=1 --report-interval=1 run >> "$RAW_RESULTS_FILE" 2>&1
echo "Benchmark complete."

# Cleanup the database
echo "Cleaning up...";
sysbench oltp_read_write $SYSBENCH_OPTS cleanup >> "$RAW_RESULTS_FILE" 2>&1
echo "Database cleanup complete."
