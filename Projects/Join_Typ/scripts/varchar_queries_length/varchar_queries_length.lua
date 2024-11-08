function prepare()
    local create_kunden_query = [[
        CREATE TABLE IF NOT EXISTS KUNDENMITVARCHARLENGTH (
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

    -- SQL query to create BESTELLUNGMITVARCHARLENGTH table
    local create_bestellung_query = [[
        CREATE TABLE IF NOT EXISTS BESTELLUNGMITVARCHARLENGTH (
            BESTELLUNG_ID INT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    VARCHAR(255) NOT NULL,
            UMSATZ       INT,
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDENMITVARCHARLENGTH (NAME)
        );
    ]]

    -- Execute the table creation queries
    db_query(create_kunden_query)
    db_query(create_bestellung_query)

    -- Log message indicating tables have been created
    print("Tables KUNDENMITVARCHARLENGTH and BESTELLUNGMITVARCHARLENGTH have been successfully created.")
end


function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDENMITVARCHARLENGTH;"
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNGMITVARCHARLENGTH;"

    db_query(drop_bestellung_query)
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end