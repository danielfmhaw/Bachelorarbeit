#!/bin/bash
number_of_replicas=${1:-3}

docker network create mysql-network

# Start Primary Container
docker run -d --name mysql-primary --network mysql-network -e MYSQL_ROOT_PASSWORD=password -p 3307:3306 mysql:8 \
            --server-id=1 --log-bin=mysql-bin
until docker exec mysql-primary mysqladmin ping -uroot -ppassword --silent &> /dev/null; do
  echo "Waiting for MySQL Primary to be ready..."
  sleep 5
done

# Start Replica Containers
for ((i=1; i<=number_of_replicas; i++)); do
  docker run -d --name mysql-replica-${i} --network mysql-network -e MYSQL_ROOT_PASSWORD=password -p $((3307 + i)):3306 mysql:8 \
    --server-id=$((i + 1)) --log-bin=mysql-bin --read-only=1
  until docker exec mysql-replica-${i} mysqladmin ping -uroot -ppassword --silent &> /dev/null; do
    echo "Waiting for MySQL Replica ${i} to be ready..."
    sleep 5
  done
done

# Fetch Binary Log Info
MASTER_STATUS=$(docker exec mysql-primary mysql -uroot -ppassword -e "SHOW BINARY LOG STATUS\G")
BINLOG_FILE=$(echo "$MASTER_STATUS" | awk '/File:/ {print $2}')
BINLOG_POS=$(echo "$MASTER_STATUS" | awk '/Position:/ {print $2}')

# Setup Primary
echo "Configuring primary MySQL server..."
docker exec -i mysql-primary mysql -uroot -ppassword -e "
CREATE DATABASE sbtest;
CREATE USER 'repl'@'%' IDENTIFIED WITH sha256_password BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
"

# Setup Replicas
for ((i=1; i<=number_of_replicas; i++)); do
  docker exec -i mysql-replica-${i} mysql -uroot -ppassword -e "
  CHANGE REPLICATION SOURCE TO
    SOURCE_HOST = 'mysql-primary',
    SOURCE_USER = 'repl',
    SOURCE_PASSWORD = 'repl_password',
    SOURCE_LOG_FILE = '$BINLOG_FILE',
    SOURCE_LOG_POS = $BINLOG_POS;
  START REPLICA;
  "
done

echo "MySQL replication setup completed."

# Run Sysbench tests
sysbench --db-driver=mysql --mysql-host=127.0.0.1 --mysql-port=3307 --mysql-user=root --mysql-password=password --mysql-db=sbtest oltp_insert --tables=1 --table-size=2500 prepare
sysbench --db-driver=mysql --mysql-host=127.0.0.1 --mysql-port=3307 --mysql-user=root --mysql-password=password --mysql-db=sbtest oltp_read_write --tables=1 --table-size=2500 run
for ((i=1; i<=number_of_replicas; i++)); do
  sysbench --db-driver=mysql --mysql-host=127.0.0.1 --mysql-port=$((3307 + i)) --mysql-user=root --mysql-password=password --mysql-db=sbtest oltp_read_only --tables=1 --table-size=2500 run
done
sysbench --db-driver=mysql --mysql-host=127.0.0.1 --mysql-port=3307 --mysql-user=root --mysql-password=password --mysql-db=sbtest oltp_insert --tables=1 --table-size=2500 cleanup

# Cleanup MySQL containers
docker ps -q -f name=mysql-primary | xargs -r docker stop | xargs -r docker rm
for ((i=1; i<=number_of_replicas; i++)); do
  docker ps -q -f name=mysql-replica-${i} | xargs -r docker stop | xargs -r docker rm
done
