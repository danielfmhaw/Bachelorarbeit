local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_query()
    count_query = "SELECT COUNT(*) FROM KUNDEN;"
    if not explain_executed then
        utils.print_results(con, count_query)
        explain_executed = true
    else
        con:query(count_query)
    end
    con:query("SELECT * FROM KUNDEN ORDER BY NAME;")
end

function event()
    select_query()
end
