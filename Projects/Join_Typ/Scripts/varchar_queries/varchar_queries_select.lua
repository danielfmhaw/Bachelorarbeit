local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_query()
    if not explain_executed then
        utils.print_results(con, "SELECT COUNT(*) FROM KUNDENMITVARCHAR k JOIN BESTELLUNGMITVARCHAR b ON k.KUNDEN_ID = b.FK_KUNDEN;")
        explain_executed = true
    end
    local join_query = [[
        SELECT k.STADT, SUM(b.UMSATZ) AS Total_Umsatz
        FROM KUNDENMITVARCHAR k
        JOIN BESTELLUNGMITVARCHAR b ON k.KUNDEN_ID = b.FK_KUNDEN
        GROUP BY k.STADT;
    ]]
    con:query(join_query)
end

function event()
    select_query()
end