local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_full_match()
    local full_match_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME = 'Max' AND GEBURTSTAG = '1960-01-01';"

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. full_match_query)
        utils.print_results(con, (full_match_query:gsub("%*", "COUNT(*)")))
        explain_executed = true
    end

    con:query(full_match_query)
end

function event()
    select_full_match()
end
