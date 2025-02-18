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

function query_for_country(country)
    return string.format([[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN AND k.LAND = b.LAND
        WHERE k.LAND = '%s'
    ]], country)
end

function select_union_multiple_countries()
    local test_countries = utils.get_random_countries(countries,5)
    local query_parts = {}

    for _, country in ipairs(test_countries) do
        table.insert(query_parts, query_for_country(country))
    end

    local union_multiple_countries_query = table.concat(query_parts, " UNION ")

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. union_multiple_countries_query)
        explain_executed = true
    end

    con:query(union_multiple_countries_query)
end

function event()
    select_union_multiple_countries()
end
