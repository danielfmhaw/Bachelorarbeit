local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_query()
    local query = "SELECT * FROM KUNDEN WHERE NAME = 'Kunde_1';"
    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. query)
        utils.print_results(con, (query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    else
        con:query(query)
    end
end

function event()
    select_query()
end
