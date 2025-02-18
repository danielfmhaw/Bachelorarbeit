DROP TABLE BESTELLUNG;
DROP TABLE KUNDEN;

SELECT *
FROM BESTELLUNG;
SELECT *
FROM KUNDEN;

-- Partitions
SELECT *
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'kunden';

-- list-partitioning: SIMPLE => works
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.LAND = 'Germany';

-- list-partitioning: IN => works
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.LAND IN ('DR Congo', 'Egypt', 'Ethiopia', 'India', 'Nigeria');

-- list-partitioning: OR => works
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.LAND != 'DR Congo'
   OR k.LAND = 'Egypt'
   OR k.LAND = 'Ethiopia'
   OR k.LAND = 'India'
   OR k.LAND = 'Nigeria';

-- list-partitioning: UNION => works
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.LAND = 'DR Congo'
UNION
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.LAND = 'Egypt'
UNION
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.LAND = 'Ethiopia'
UNION
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.LAND = 'India'
UNION
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.LAND = 'Nigeria';

-- range-partitioning: failing => works as expected (all partitions)
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE YEAR(k.GEBURTSTAG) = 1985;

-- range-partitioning: primary key  => works (only one partition)
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.GEBURTSTAG = '1985-01-01';

-- range-partitioning: with pruning => works (only one partition)
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE k.GEBURTSTAG BETWEEN '1985-01-01' AND '1985-12-31';

-- hash-partitioning: simple => works (only one partition)
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE KUNDEN_ID = 1000;

-- hash-partitioning: range => all partitions
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE KUNDEN_ID BETWEEN 1000 AND 2000;

-- hash-partitioning: mod => all partitions
EXPLAIN
SELECT *
FROM KUNDEN k
         JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
WHERE MOD(KUNDEN_ID, 4) = 0;

-- same result as
EXPLAIN
SELECT *
FROM KUNDEN PARTITION (p0)
JOIN BESTELLUNG b ON KUNDEN_ID = b.FK_KUNDEN;





