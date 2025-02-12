local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")
local format = os.getenv("FORMAT")

function prepare()
    -- SQL query to create the KUNDEN table without auto-increment for KUNDEN_ID
    local create_kunden_query = [[
        CREATE TABLE IF NOT EXISTS KUNDEN (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]]

    -- SQL query to create the BESTELLUNG table
    local create_bestellung_query = [[
        CREATE TABLE IF NOT EXISTS BESTELLUNG (
            BESTELLUNG_ID INT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    INT NOT NULL,
            UMSATZ       INT,
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDEN (KUNDEN_ID)
        );
    ]]

    if format and format ~= "" then
        con:query(string.format("SET SESSION binlog_format = '%s';", format:upper()))
        utils.print_results(con:query("SHOW VARIABLES LIKE 'binlog_format';"))
    end

    con:query(create_kunden_query)
    con:query(create_bestellung_query)
    print("Tables KUNDEN and BESTELLUNG have been successfully created.")
end

function cleanup()
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNG;"
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"

    con:query(drop_bestellung_query)
    con:query(drop_kunden_query)
    print("Cleanup successfully done")
end