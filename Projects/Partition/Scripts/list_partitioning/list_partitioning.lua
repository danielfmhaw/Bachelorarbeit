local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")

local countries = {
    "China", "India", "United States", "Indonesia", "Pakistan",
    "Brazil", "Nigeria", "Bangladesh", "Russia", "Mexico",
    "Japan", "Ethiopia", "Philippines", "Egypt", "Vietnam",
    "DR Congo", "Turkey", "Iran", "Germany", "Thailand"
}

function prepare()
     -- SQL query to create the KUNDEN table without range partition
     local partition_sql = utils.generate_list_partitions(countries)
     local create_kunden_query = string.format([[
         CREATE TABLE IF NOT EXISTS KUNDEN (
             KUNDEN_ID     INT NOT NULL,
             NAME          VARCHAR(255),
             GEBURTSTAG    DATE NOT NULL,
             ADRESSE       VARCHAR(255),
             STADT         VARCHAR(100),
             POSTLEITZAHL  VARCHAR(10),
             LAND          VARCHAR(100) NOT NULL,
             EMAIL         VARCHAR(255),
             TELEFONNUMMER VARCHAR(20),
             PRIMARY KEY (KUNDEN_ID, GEBURTSTAG, LAND)
         )
         PARTITION BY LIST COLUMNS(LAND) (
             %s
         );
     ]], partition_sql)

    -- SQL query to create the BESTELLUNG table
    local create_bestellung_query = [[
        CREATE TABLE IF NOT EXISTS BESTELLUNG (
            BESTELLUNG_ID INT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    INT NOT NULL,
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