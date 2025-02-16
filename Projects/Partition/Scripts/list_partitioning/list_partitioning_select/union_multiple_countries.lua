local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")

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
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.LAND = '%s'
    ]], country)
end

function union_mutliple_countries_query()
    local test_countries = utils.get_random_countries(countries,5)
    local query_parts = {}

    for _, country in ipairs(test_countries) do
        table.insert(query_parts, query_for_country(country))
    end

    local final_query = table.concat(query_parts, " UNION ")
    print("Executing query for countries: " .. table.concat(countries, ", "))
    con:query(final_query)
end

function event()
    union_mutliple_countries_query()
end
