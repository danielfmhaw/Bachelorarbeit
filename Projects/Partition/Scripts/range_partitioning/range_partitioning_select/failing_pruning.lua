local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_failing_pruning()
    local failing_pruning_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE YEAR(k.GEBURTSTAG) = 1985;
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. failing_pruning_query)
        explain_executed = true
    end

    con:query(failing_pruning_query)
end

function event()
    select_failing_pruning()
end
