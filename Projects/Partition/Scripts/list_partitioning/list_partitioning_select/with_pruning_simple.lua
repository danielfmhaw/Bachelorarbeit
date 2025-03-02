local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_with_pruning_simple()
    local with_pruning_simple_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN AND k.LAND = b.LAND
        WHERE k.LAND = 'Germany';
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. with_pruning_simple_query)
        utils.print_results(con, (with_pruning_simple_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(with_pruning_simple_query)
end

function event()
    select_with_pruning_simple()
end