local con = sysbench.sql.driver():connect()
function prepare()
    -- SQL query to create the KUNDENMITID table without auto-increment for KUNDEN_ID
    local create_kunden_query = [[
        CREATE TABLE KUNDENMITID (
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
    ]]

    -- SQL query to create the BESTELLUNGMITID table
    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNGMITID (
            BESTELLUNG_ID INT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    BIGINT NOT NULL,
            UMSATZ       INT,
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDENMITID (KUNDEN_ID)
        );
    ]]

    con:query(create_kunden_query)
    con:query(create_bestellung_query)
    print("Tables KUNDENMITID and BESTELLUNGMITID have been successfully created.")
end

function cleanup()
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNGMITID;"
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDENMITID;"

    con:query(drop_bestellung_query)
    con:query(drop_kunden_query)
    print("Cleanup successfully done")
end