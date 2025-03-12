local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_with_pruning_first_day_1985()
    local with_pruning_first_day_1985_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.GEBURTSTAG = '1985-01-01';
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. with_pruning_first_day_1985_query)
        utils.print_results(con, (with_pruning_first_day_1985_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(with_pruning_first_day_1985_query)
end

function event()
    select_with_pruning_first_day_1985()
end