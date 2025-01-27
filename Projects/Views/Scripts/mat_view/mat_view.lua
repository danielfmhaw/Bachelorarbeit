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
           BESTELLUNG_ID SERIAL PRIMARY KEY,
           BESTELLDATUM DATE,
           ARTIKEL_ID   INT,
           UMSATZ       INT,
           FK_KUNDEN    INT NOT NULL,
           FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDEN (KUNDEN_ID) ON DELETE CASCADE
       );
    ]]

    local create_materialized_view_query = [[
        CREATE MATERIALIZED VIEW KUNDEN_MAT_OVERVIEW AS
        SELECT
            EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr,
            K.LAND AS Land,
            SUM(B.UMSATZ) AS Gesamtumsatz
        FROM KUNDEN K
                 JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
        GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;
    ]]

    con:query(create_kunden_query)
    con:query(create_bestellung_query)
    con:query(create_materialized_view_query)

    print("Table 'KUNDEN', Table 'BESTELLUNG' and Materialized View 'KUNDEN_MAT_OVERVIEW' have been successfully created.")
end

function cleanup()
    con:query("DROP MATERIALIZED VIEW IF EXISTS KUNDEN_MAT_OVERVIEW;")
    con:query("DROP TABLE IF EXISTS BESTELLUNG;")
    con:query("DROP TABLE IF EXISTS KUNDEN;")

    print("Cleanup successfully done.")
end