local size = tostring(os.getenv("TYP")) or ""
size = size:gsub("([a-zA-Z]+)_(%d+)", "%1(%2)")

function prepare()
    local create_kunden_query = string.format([[
        CREATE TABLE IF NOT EXISTS KUNDEN (
            NAME          %s PRIMARY KEY,
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]], size)

    db_query(create_kunden_query)
    print(string.format("Table 'KUNDEN' has been successfully created with KUNDEN_ID size: %s.", size))
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end