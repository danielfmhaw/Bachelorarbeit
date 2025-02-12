local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")

local counts_executed = false

function select_query()
    local join_query = [[
        SELECT k.STADT, SUM(b.UMSATZ) AS Total_Umsatz
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        GROUP BY k.STADT;
    ]]
    if not counts_executed then
        utils.print_results(con:query("SELECT COUNT(*) FROM KUNDEN"))
        utils.print_results(con:query("SELECT COUNT(*) FROM BESTELLUNG"))
        utils.print_results(con:query("SELECT COUNT(*) FROM KUNDEN k JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN"))

        counts_executed = true
    end

    con:query(join_query)
end

function event()
    select_query()
end