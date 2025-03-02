local con = sysbench.sql.driver():connect()
function prepare()
    -- Create Table Kunden with varchar as PK
    local create_kunden_query = [[
        CREATE TABLE IF NOT EXISTS KUNDENMITVARCHAR (
            NAME          VARCHAR(255) PRIMARY KEY,
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]]

    -- SQL query to create BESTELLUNGMITVARCHAR table
    local create_bestellung_query = [[
        CREATE TABLE IF NOT EXISTS BESTELLUNGMITVARCHAR (
            BESTELLUNG_ID INT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN_NAME    VARCHAR(255) NOT NULL,
            UMSATZ       INT,
            FOREIGN KEY (FK_KUNDEN_NAME) REFERENCES KUNDENMITVARCHAR (NAME)
        );
    ]]

    -- Execute the table creation queries
    con:query(create_kunden_query)
    con:query(create_bestellung_query)

    -- Log message indicating tables have been created
    print("Tables KUNDENMITVARCHAR and BESTELLUNGMITVARCHAR have been successfully created.")
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDENMITVARCHAR;"
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNGMITVARCHAR;"

    con:query(drop_bestellung_query)
    con:query(drop_kunden_query)
    print("Cleanup successfully done")
end