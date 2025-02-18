local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")
local use_range_columns = (os.getenv("TYPE") or "") == "range_columns"

function prepare()
     local partition_sql = utils.generate_partition_definition_by_year(1950, 2020, 5, use_range_columns)
     -- SQL query to create the KUNDEN table with range partition
     local create_kunden_query = string.format([[
         CREATE TABLE KUNDEN (
             KUNDEN_ID     INT,
             NAME          VARCHAR(255),
             GEBURTSTAG    DATE,
             ADRESSE       VARCHAR(255),
             STADT         VARCHAR(100),
             POSTLEITZAHL  VARCHAR(10),
             LAND          VARCHAR(100),
             EMAIL         VARCHAR(255),
             TELEFONNUMMER VARCHAR(20),
             PRIMARY KEY (KUNDEN_ID, GEBURTSTAG)
         ) %s
     ]],partition_sql)

    -- SQL query to create the BESTELLUNG table
    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNG (
            BESTELLUNG_ID INT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    INT,
            UMSATZ       INT
        );
    ]]

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