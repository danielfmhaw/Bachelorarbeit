local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_exact_with_prefix()
    local exact_with_prefix_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME LIKE 'M%' ORDER BY GEBURTSTAG;"

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. exact_with_prefix_query)
        utils.print_results(con, (exact_with_prefix_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(exact_with_prefix_query)
end

function event()
    select_exact_with_prefix()
end
