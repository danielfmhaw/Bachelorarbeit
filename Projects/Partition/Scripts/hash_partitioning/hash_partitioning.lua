local con = sysbench.sql.driver():connect()
local type = os.getenv("TYPE") and tostring(os.getenv("TYPE")) or "HASH"
local count = tonumber(os.getenv("PARTITIONS_SIZE")) or 5

function prepare()
     -- SQL query to create the KUNDEN table without range partition
     local create_kunden_query = string.format([[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     INT,
            NAME          VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255),
            TELEFONNUMMER VARCHAR(20),
            PRIMARY KEY (KUNDEN_ID)
        )
        PARTITION BY %s (KUNDEN_ID)
        PARTITIONS %d;
    ]], type:upper(), count)

    -- SQL query to create the BESTELLUNG table
    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNG (
            BESTELLUNG_ID INT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    INT,
            UMSATZ       INT
        );
    ]]

    con:query(create_kunden_query)
    con:query(create_bestellung_query)
    print("Tables KUNDEN and BESTELLUNG have been successfully created.")
end

function cleanup()
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNG;"
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"

    con:query(drop_bestellung_query)
    con:query(drop_kunden_query)
    print("Cleanup successfully done")
end