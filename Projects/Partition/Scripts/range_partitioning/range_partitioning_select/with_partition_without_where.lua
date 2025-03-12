local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_without_where()
    local without_where_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. without_where_query)
        utils.print_results(con, (without_where_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(without_where_query)
end

function event()
    select_without_where()
end
