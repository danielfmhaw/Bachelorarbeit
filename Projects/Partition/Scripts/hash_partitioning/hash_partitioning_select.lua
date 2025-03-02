local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_kunde_id_range()
    local kunde_id_range_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE KUNDEN_ID BETWEEN 1000 AND 2000;
    ]];

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. kunde_id_range_query)
        utils.print_results(con, (kunde_id_range_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(kunde_id_range_query)
end

function event()
    select_kunde_id_range()
end