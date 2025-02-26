local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_combined_match_with_range()
    local combined_match_with_range_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME = 'Max' AND GEBURTSTAG < '1980-01-01';"

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. combined_match_with_range_query)
        utils.print_results(con, combined_match_with_range_query:gsub("%*", "COUNT(*)"))
        explain_executed = true
    end

    con:query(combined_match_with_range_query)
end

function event()
    select_combined_match_with_range()
end
