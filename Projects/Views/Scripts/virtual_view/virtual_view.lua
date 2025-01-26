function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     INT AUTO_INCREMENT PRIMARY KEY,
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

    local create_view_query = [[
        CREATE VIEW KUNDEN_OVERVIEW AS
        SELECT
            LAND,
            COUNT(*) AS ANZAHL_KUNDEN
        FROM KUNDEN
        WHERE LAND IS NOT NULL
          AND TIMESTAMPDIFF(YEAR, GEBURTSTAG, CURDATE()) < 50
        GROUP BY LAND;
    ]]

    db_query(create_kunden_query)
    db_query(create_view_query)
    print("Table 'KUNDEN' and View 'KUNDEN_OVERVIEW' have been successfully created.")
end

function cleanup()
    local drop_view_query = "DROP VIEW IF EXISTS KUNDEN_OVERVIEW;"
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    db_query(drop_view_query)
    db_query(drop_kunden_query)
    print("Cleanup successfully done.")
end
