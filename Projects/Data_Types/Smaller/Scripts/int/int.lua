local con = sysbench.sql.driver():connect()
local size = tostring(os.getenv("DATATYP")) or ""
size = size:gsub("([a-zA-Z]+)_(%d+)", "%1(%2)")

function prepare()
    local create_kunden_query = string.format([[
        CREATE TABLE IF NOT EXISTS KUNDEN (
            KUNDEN_ID     %s PRIMARY KEY,
            NAME          VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]], size)

    con:query(create_kunden_query)
    print("Table 'KUNDEN' has been successfully created")
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    con:query(drop_kunden_query)
    print("Cleanup successfully done")
end