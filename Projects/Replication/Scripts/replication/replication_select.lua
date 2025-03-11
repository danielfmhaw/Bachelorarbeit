local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")
local dbms = tostring(os.getenv("CUSTOM_DB_NAME")) or ""

local counts_executed = false
local counter = 0

function select_query()
    counter = counter + 1
    local join_query = [[
        SELECT k.STADT, SUM(b.UMSATZ) AS Total_Umsatz
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        GROUP BY k.STADT;
    ]]
    if not counts_executed then
        utils.print_results(con, "SELECT COUNT(*) FROM KUNDEN k JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN", "KUNDENMITBESTELLUNG")
        utils.print_results(con, "SELECT COUNT(*) FROM KUNDEN", "KUNDEN")
        utils.print_results(con, "SELECT COUNT(*) FROM BESTELLUNG", "BESTELLUNG")
        counts_executed = true
    end

    if dbms == "mysql" and counter % 200 == 0 then
        utils.get_cpu_usage()
    end

    con:query(join_query)
end

function event()
    select_query()
end
