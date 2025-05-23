local con = sysbench.sql.driver():connect()
local with_index = not (os.getenv("NO") == "index")

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
        CREATE INDEX combined_index ON KUNDEN (NAME, VORNAME, GEBURTSTAG) USING HASH;
    ]]

    con:query(create_kunden_query)

    if with_index then
        con:query(create_indices)
    end
    print("Table 'KUNDEN' and index have been successfully created.")
end

function cleanup()
    if with_index then
        con:query("DROP INDEX combined_index ON KUNDEN;")
    end
    con:query("DROP TABLE IF EXISTS KUNDEN;")

    print("Cleanup successfully done.")
end
