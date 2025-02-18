local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_with_pruning()
    local with_pruning_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.GEBURTSTAG BETWEEN '1985-01-01' AND '1985-12-31';
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. with_pruning_query)
        explain_executed = true
    end

    con:query(with_pruning_query)
end

function event()
    select_with_pruning()
end
