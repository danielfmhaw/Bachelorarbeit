local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_query()
    if not explain_executed then
        utils.print_results(con, "SELECT COUNT(*) FROM KUNDEN;")
        explain_executed = true
    end
    con:query("SELECT * FROM KUNDEN WHERE STADT = 'City_7' OR STADT = 'City_10';")
    con:query("SELECT NAME, GEBURTSTAG FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01';")
    con:query("SELECT STADT, COUNT(*) AS num_customers FROM KUNDEN GROUP BY STADT;")
end

function event()
    select_query()
end
