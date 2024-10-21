#!/bin/bash

# Database connection parameters
DB_HOST="localhost"
DB_USER="root"
DB_PASS="password"
DB_NAME="sbtest"
TABLES=10
TABLE_SIZE=10000
DURATION=10

# Clear the results file
echo "Time(s),TPS,Latency(ms),Queries" > results.csv

# Run Sysbench in a loop for the specified duration
for ((i=1; i<=DURATION; i++)); do
    # Run Sysbench for 1 second
    OUTPUT=$(sysbench --db-driver=mysql --mysql-host=$DB_HOST --mysql-user=$DB_USER --mysql-password=$DB_PASS --mysql-db=$DB_NAME oltp_read_write --tables=$TABLES --table-size=$TABLE_SIZE --time=1 run)

    # Extract metrics using grep and awk, ensuring no extra characters are included
    TPS=$(echo "$OUTPUT" | grep "queries:" | awk '{print $3}' | tr -d '()')  # Remove parentheses
    LATENCY=$(echo "$OUTPUT" | grep "avg:" | awk '{print $2}' | tr -d '()')  # Remove parentheses
    TOTAL_QUERIES=$(echo "$OUTPUT" | grep "total:" | awk '{print $2}' | tr -d '()')  # Remove parentheses

    # Print and save the metrics
    echo "$i,$TPS,$LATENCY,$TOTAL_QUERIES" >> results.csv

    # Sleep for a second before the next iteration
    sleep 1
done
