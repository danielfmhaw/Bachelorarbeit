function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          VARCHAR(255),
            VORNAME    VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        )ENGINE=MEMORY;
    ]]

    local create_indices = [[
        CREATE INDEX combined_index
        ON KUNDEN (NAME);
        USING HASH;
    ]]

    db_query(create_kunden_query)
    db_query(create_indices)
    print("Table 'KUNDEN' and indices have been successfully created.")
end

function cleanup()
    db_query("DROP INDEX combined_index ON KUNDEN;")

    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    db_query(drop_kunden_query)

    print("Cleanup successfully done.")
end
