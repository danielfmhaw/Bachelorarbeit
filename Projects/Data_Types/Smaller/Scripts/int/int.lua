local size = tonumber(os.getenv("CUSTOM_LENGTH")) or 0

function prepare()
    local kunden_id_type
    if size <= 32 then
        kunden_id_type = string.format("INT(%d)", size)  -- Use INT with the specified size
    elseif size <= 64 then
        kunden_id_type = string.format("BIGINT(%d)", size)  -- Use BIGINT with the specified size
    else
        kunden_id_type = "BIGINT(64)"  -- Use BIGINT with a fixed size of 64 if size > 64
    end


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
    ]], kunden_id_type)

    db_query(create_kunden_query)
    print("Table 'KUNDEN' has been successfully created with KUNDEN_ID type:", kunden_id_type)
end

function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end