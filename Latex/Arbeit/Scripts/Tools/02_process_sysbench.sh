# Zunächst folgendes definieren : DB_HOST, DB_USER, DB_PASS, DB_NAME, TABLES, TABLE_SIZE, DURATION
SYSBENCH_CONFIG="--db-driver=mysql --mysql-host=$DB_HOST --mysql-user=$DB_USER --mysql-password=$DB_PASS --mysql-db=$DB_NAME --tables=$TABLES --table-size=$TABLE_SIZE"

sysbench oltp_read_write $SYSBENCH_CONFIG prepare
sysbench oltp_read_write $SYSBENCH_CONFIG --time=$DURATION --threads=1 --report-interval=1 run
sysbench oltp_read_write $SYSBENCH_CONFIG cleanup