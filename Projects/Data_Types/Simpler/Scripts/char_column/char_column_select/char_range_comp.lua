local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_range_comp()
    range_comp_query= "SELECT * FROM KUNDEN WHERE KUNDEN_ID > 1234;"

    if not explain_executed then
        utils.print_results(con, (range_comp_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(range_comp_query)
end

function event()
    select_range_comp()
end
