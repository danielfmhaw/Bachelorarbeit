local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_column_prefix()
    local column_prefix_query = "SELECT * FROM KUNDEN WHERE NAME LIKE 'M%';"

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. column_prefix_query)
        utils.print_results(con, column_prefix_query:gsub("%*", "COUNT(*)"))
        explain_executed = true
    end

    con:query(column_prefix_query)
end

function event()
    select_column_prefix()
end
