local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_desc_sort()
    desc_sort_query = "SELECT * FROM KUNDEN ORDER BY KUNDEN_ID DESC;"

    if not explain_executed then
        utils.print_results(con, (desc_sort_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(desc_sort_query)
end

function event()
    select_desc_sort()
end
