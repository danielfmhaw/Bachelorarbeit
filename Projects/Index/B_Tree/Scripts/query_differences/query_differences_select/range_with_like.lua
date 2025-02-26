local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_range_with_like()
    local range_with_like_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME LIKE 'M%' AND GEBURTSTAG < '1980-01-01';"

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. range_with_like_query)
        utils.print_results(con, range_with_like_query:gsub("%*", "COUNT(*)"))
        explain_executed = true
    end

    con:query(range_with_like_query)
end

function event()
    select_range_with_like()
end
