local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")

local countries = {
    "China", "India", "United States", "Indonesia", "Pakistan",
    "Brazil", "Nigeria", "Bangladesh", "Russia", "Mexico",
    "Japan", "Ethiopia", "Philippines", "Egypt", "Vietnam",
    "DR Congo", "Turkey", "Iran", "Germany", "Thailand"
}

function mutliple_countries_query()
    local test_countries = utils.get_random_countries(countries,5)
    local where_clause = {}

    for _, country in ipairs(test_countries) do
        table.insert(where_clause, string.format("'%s'", country))
    end

    local join_query = string.format([[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.LAND IN (%s);
    ]], table.concat(where_clause, ", "))

    print("Executing query for these random countries: ", table.concat(test_countries, ", "))
    con:query(join_query)
end

function event()
    mutliple_countries_query()
end
