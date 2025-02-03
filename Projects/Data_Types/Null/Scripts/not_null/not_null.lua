local con = sysbench.sql.driver():connect()
function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          VARCHAR(255) NOT NULL,
            GEBURTSTAG    DATE NOT NULL,
            ADRESSE       VARCHAR(255) NOT NULL,
            STADT         VARCHAR(100) NOT NULL,
            POSTLEITZAHL  VARCHAR(10) NOT NULL,
            LAND          VARCHAR(100) NOT NULL,
            EMAIL         VARCHAR(255) UNIQUE NOT NULL,
            TELEFONNUMMER VARCHAR(20) NOT NULL
        );
    ]]

    con:query(create_kunden_query)
    print("Table 'KUNDEN' has been successfully created.")
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    con:query(drop_kunden_query)
    print("Cleanup successfully done")
end