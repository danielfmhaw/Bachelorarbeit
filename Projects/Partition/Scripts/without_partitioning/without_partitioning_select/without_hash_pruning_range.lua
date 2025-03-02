local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_without_hash_pruning_range()
    local without_hash_pruning_range_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE KUNDEN_ID BETWEEN 1000 AND 2000;
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. without_hash_pruning_range_query)
        utils.print_results(con, (without_hash_pruning_range_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(without_hash_pruning_range_query)
end

function event()
    select_without_hash_pruning_range()
end