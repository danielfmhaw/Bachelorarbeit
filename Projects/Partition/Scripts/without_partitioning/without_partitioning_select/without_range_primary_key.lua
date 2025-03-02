local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_without_range_direct()
    local without_range_direct_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.GEBURTSTAG = '1985-01-01';
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. without_range_direct_query)
        utils.print_results(con, (without_range_direct_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(without_range_direct_query)
end

function event()
    select_without_range_direct()
end