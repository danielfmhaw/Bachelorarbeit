local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_without_list_pruning_simple()
    local without_list_pruning_simple_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.LAND = 'Germany';
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. without_list_pruning_simple_query)
        explain_executed = true
    end

    con:query(without_list_pruning_simple_query)
end

function event()
    select_without_list_pruning_simple()
end