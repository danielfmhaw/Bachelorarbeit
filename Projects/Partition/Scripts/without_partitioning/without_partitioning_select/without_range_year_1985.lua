local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_without_range_year_1985()
    local without_range_year_1985_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE YEAR(k.GEBURTSTAG) = 1985;
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. without_range_year_1985_query)
        utils.print_results(con, (without_range_year_1985_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(without_range_year_1985_query)
end

function event()
    select_without_range_year_1985()
end