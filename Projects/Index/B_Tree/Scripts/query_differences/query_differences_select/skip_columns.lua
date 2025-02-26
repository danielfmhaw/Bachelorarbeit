local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_skip_columns()
    local skip_columns_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND GEBURTSTAG < '1980-01-01';"

    if not explain_executed then
        utils.print_results(con, "EXPLAIN " .. skip_columns_query)
        utils.print_results(con, skip_columns_query:gsub("%*", "COUNT(*)"))
        explain_executed = true
    end

    con:query(skip_columns_query)
end

function event()
    select_skip_columns()
end
