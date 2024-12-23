function prepare()
    local create_kunden_query = [[
        CREATE TABLE IF NOT EXISTS KUNDEN (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          VARCHAR(255) NOT NULL,
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]]

    db_query(create_kunden_query)
    print("Table 'KUNDEN' has been successfully created.")
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end