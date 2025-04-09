-- Join Type
CREATE TABLE KUNDEN (
    KUNDEN_ID     BIGINT PRIMARY KEY,
    NAME          VARCHAR(255),
    GEBURTSTAG    DATE,
    ADRESSE       VARCHAR(255),
    STADT         VARCHAR(100),
    POSTLEITZAHL  VARCHAR(10),
    LAND          VARCHAR(100),
    EMAIL         VARCHAR(255) UNIQUE,
    TELEFONNUMMER VARCHAR(20)
);

CREATE TABLE BESTELLUNG (
    BESTELLUNG_ID INT PRIMARY KEY,
    BESTELLDATUM DATE,
    ARTIKEL_ID   INT,
    FK_KUNDEN    BIGINT NOT NULL,
    UMSATZ       INT,
    FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDEN (KUNDEN_ID)
);

-- B-Tree
CREATE INDEX combined_index ON KUNDEN(NAME, VORNAME, GEBURTSTAG);
SELECT * FROM KUNDEN WHERE NAME LIKE 'M%'; -- columm_prefix
SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME = 'Max' AND GEBURTSTAG < '1980-01-01'; -- combined_match_with_range
SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME LIKE 'M%' ORDER BY GEBURTSTAG; -- exact_with_prefix
SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME = 'Max' AND GEBURTSTAG = '1960-01-01'; -- full_match
SELECT * FROM KUNDEN WHERE NAME = 'Müller'; -- leftmost_prefix
SELECT * FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01'; -- not_leftmost
SELECT * FROM KUNDEN WHERE NAME BETWEEN 'Müller' AND 'Schulz'; -- range_values
SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME LIKE 'M%' AND GEBURTSTAG < '1980-01-01'; -- range_with_like
SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND GEBURTSTAG < '1980-01-01'; -- skip_columns

-- Views
CREATE VIEW KUNDEN_OVERVIEW AS
SELECT
    EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr,
    K.LAND AS Land,
    SUM(B.UMSATZ) AS Gesamtumsatz
FROM KUNDEN K
         JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;

-- MatViews mit Trigger
CREATE TABLE KUNDEN_MAT_OVERVIEW(
    JAHR         INT,
    LAND         VARCHAR(100),
    GESAMTUMSATZ INT,
    PRIMARY KEY (JAHR,LAND)
);

CREATE TRIGGER UPDATE_BESTELLUNG_MAT_OVERVIEW_AFTER_INSERT
AFTER INSERT ON BESTELLUNG
FOR EACH ROW
BEGIN
    DECLARE v_land VARCHAR(255);
    DECLARE v_jahr INT;
    SELECT LAND INTO v_land FROM KUNDEN WHERE KUNDEN_ID = NEW.FK_KUNDEN;
    SELECT EXTRACT(YEAR FROM NEW.BESTELLDATUM) INTO v_jahr;

    IF EXISTS (
        SELECT 1
        FROM KUNDEN_MAT_OVERVIEW
        WHERE LAND = v_land AND JAHR = v_jahr
    ) THEN
        UPDATE KUNDEN_MAT_OVERVIEW
        SET GESAMTUMSATZ = GESAMTUMSATZ + NEW.UMSATZ
        WHERE LAND = v_land AND JAHR = v_jahr;
    ELSE
        INSERT INTO KUNDEN_MAT_OVERVIEW (JAHR, LAND, GESAMTUMSATZ)
        VALUES (v_jahr, v_land, NEW.UMSATZ);
    END IF;
END;

CREATE TRIGGER UPDATE_BESTELLUNG_MAT_OVERVIEW_AFTER_DELETE
    AFTER DELETE ON BESTELLUNG
    FOR EACH ROW
BEGIN
    DECLARE v_land VARCHAR(255);
    DECLARE v_jahr INT;
    SELECT LAND INTO v_land FROM KUNDEN WHERE KUNDEN_ID = OLD.FK_KUNDEN;
    SELECT EXTRACT(YEAR FROM OLD.BESTELLDATUM) INTO v_jahr;

    IF EXISTS (
        SELECT 1
        FROM KUNDEN_MAT_OVERVIEW
        WHERE LAND = v_land AND JAHR = v_jahr
    ) THEN
        UPDATE KUNDEN_MAT_OVERVIEW
        SET GESAMTUMSATZ = GESAMTUMSATZ - OLD.UMSATZ
        WHERE LAND = v_land AND JAHR = v_jahr;
    END IF;
END;

-- MatViews
CREATE MATERIALIZED VIEW KUNDEN_MAT_OVERVIEW AS
SELECT
    EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr,
    K.LAND AS Land,
    SUM(B.UMSATZ) AS Gesamtumsatz
FROM KUNDEN K
         JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;

-- Lua-Skript: Prepare
local con = sysbench.sql.driver():connect()
function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]]
    con:query(create_kunden_query)
    print("Table KUNDEN has been successfully created.")
end

-- Lua-Skript: Insert
local con = sysbench.sql.driver():connect()
local num_rows = 1000

function delete_data()
    con:query("DELETE FROM BESTELLUNG;")
    con:query("DELETE FROM KUNDEN;")
end

function insert_data()
    delete_data()
    for i = 1, num_rows do
        local kunden_id = i -- define name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer
        local kunden_query = string.format([[
            INSERT INTO KUNDEN
            (KUNDEN_ID, NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
            VALUES (%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
        ]], kunden_id, name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)
        con:query(kunden_query)
    end
end

function event()
    insert_data()
end

-- Lua-Skript: Select
local con = sysbench.sql.driver():connect()
function select_query()
    con:query("SELECT * FROM KUNDEN ORDER BY NAME ASC;")
    con:query("SELECT LAND, COUNT(*) FROM KUNDEN GROUP BY LAND;")
    con:query("SELECT * FROM KUNDEN WHERE EMAIL = 'customer100@example.com';")
    con:query("SELECT COUNT(*) FROM KUNDEN WHERE STADT LIKE 'City_%';")
    con:query("SELECT STADT,COUNT(*) FROM KUNDEN GROUP BY STADT;")
end

function event()
    select_query()
end

-- Lua-Skript: Cleanup
local con = sysbench.sql.driver():connect()
function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    con:query(drop_kunden_query)

    print("Cleanup successfully done")
end


-- Ohne View
SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, K.LAND AS Land, SUM(B.UMSATZ) AS Gesamtumsatz
FROM KUNDEN K
         JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
WHERE EXTRACT(YEAR FROM B.BESTELLDATUM) = 2020
GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;
SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, K.LAND AS Land, SUM(B.UMSATZ) AS Gesamtumsatz
FROM KUNDEN K
         JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND
HAVING SUM(B.UMSATZ) > 2500;

-- View
CREATE VIEW KUNDEN_OVERVIEW AS
SELECT
    EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr,
    K.LAND AS Land,
    SUM(B.UMSATZ) AS Gesamtumsatz
FROM KUNDEN K
         JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;