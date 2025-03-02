local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_range_values()
    local range_values_query = "SELECT * FROM KUNDEN WHERE NAME BETWEEN 'Müller' AND 'Schulz';"

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. range_values_query)
        utils.print_results(con, (range_values_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(range_values_query)
end

function event()
    select_range_values()
end
