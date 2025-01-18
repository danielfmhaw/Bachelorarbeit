local size = tostring(os.getenv("TYP")) or ""
size = size:gsub("([a-zA-Z]+)_(%d+)", "%1(%2)")

function prepare()
    local create_kunden_query = string.format([[
        CREATE TABLE IF NOT EXISTS KUNDEN (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          %s,
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]], size)

    local create_indices = [[
        CREATE INDEX idx_name ON KUNDEN(NAME);
    ]]

    db_query(create_kunden_query)
    db_query(create_indices)
    print(string.format("Table 'KUNDEN' has been successfully created with type %s for column 'NAME'", size))
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    local drop_index_query = "DROP INDEX idx_name ON KUNDEN;"

    db_query(drop_index_query)
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end