local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_query()
    if not explain_executed then
        utils.print_results(con, "SELECT COUNT(*) FROM KUNDEN_OVERVIEW;")
        explain_executed = true
    end
    con:query("SELECT Jahr, SUM(Gesamtumsatz) AS UmsatzProJahr FROM KUNDEN_OVERVIEW GROUP BY Jahr;")
    con:query("SELECT * FROM KUNDEN_OVERVIEW WHERE Jahr = 2020;")
    con:query("SELECT * FROM KUNDEN_OVERVIEW WHERE Land = 'Germany';")
    con:query("SELECT * FROM KUNDEN_OVERVIEW WHERE Gesamtumsatz > 2500;")
end

function event()
    select_query()
end
