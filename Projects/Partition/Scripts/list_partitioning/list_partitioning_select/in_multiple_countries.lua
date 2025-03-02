local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

local countries = {
    "China", "India", "United States", "Indonesia", "Pakistan",
    "Brazil", "Nigeria", "Bangladesh", "Russia", "Mexico",
    "Japan", "Ethiopia", "Philippines", "Egypt", "Vietnam",
    "DR Congo", "Turkey", "Iran", "Germany", "Thailand"
}

function select_in_multiple_countries()
    local test_countries = utils.get_random_countries(countries,5)
    local where_clause = {}

    for _, country in ipairs(test_countries) do
        table.insert(where_clause, string.format("'%s'", country))
    end

    local in_multiple_countries_query = string.format([[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN AND k.LAND = b.LAND
        WHERE k.LAND IN (%s);
    ]], table.concat(where_clause, ", "))

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. in_multiple_countries_query)
        utils.print_results(con, (in_multiple_countries_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(in_multiple_countries_query)
end

function event()
    select_in_multiple_countries()
end
