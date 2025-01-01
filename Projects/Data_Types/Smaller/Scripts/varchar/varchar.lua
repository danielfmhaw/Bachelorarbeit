local size = tonumber(os.getenv("LENGTH")) or 0

function prepare()
    local kunden_id_size = size > 0 and size or 255

    local create_kunden_query = string.format([[
        CREATE TABLE IF NOT EXISTS KUNDEN (
            KUNDEN_ID     VARCHAR(%d) PRIMARY KEY,
            NAME          VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]], kunden_id_size)

    db_query(create_kunden_query)
    print(string.format("Table 'KUNDEN' has been successfully created with KUNDEN_ID size: %d.", kunden_id_size))
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end
