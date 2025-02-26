local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_not_leftmost()
    local not_leftmost_query = "SELECT * FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01';"

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. not_leftmost_query)
        utils.print_results(con, not_leftmost_query:gsub("%*", "COUNT(*)"))
        explain_executed = true
    end

    con:query(not_leftmost_query)
end

function event()
    select_not_leftmost()
end
