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
            EMAIL         VARCHAR(255),
            TELEFONNUMMER VARCHAR(20)
        );
    ]]

    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNG (
            BESTELLUNG_ID INT AUTO_INCREMENT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            UMSATZ       INT,
            FK_KUNDEN    INT NOT NULL,
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDEN (KUNDEN_ID) ON DELETE CASCADE
        );
    ]]

    con:query(create_kunden_query)
    con:query(create_bestellung_query)
    print("Table 'KUNDEN' and Table 'BESTELLUNG' has been successfully created.")
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNG;"

    con:query(drop_bestellung_query)
    con:query(drop_kunden_query)
    print("Cleanup successfully done")
end