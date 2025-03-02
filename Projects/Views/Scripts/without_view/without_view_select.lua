local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_query()
    if not explain_executed then
        utils.print_results(con, [[
            SELECT COUNT(*)
            FROM (
                SELECT 1
                FROM KUNDEN K
                JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
                GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND
            ) AS subquery;
        ]])
        explain_executed = true
    end
    con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, SUM(B.UMSATZ) AS UmsatzProJahr FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM);")
    con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, K.LAND AS Land, SUM(B.UMSATZ) AS Gesamtumsatz FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN WHERE EXTRACT(YEAR FROM B.BESTELLDATUM) = 2020 GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;")
    con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, K.LAND AS Land, SUM(B.UMSATZ) AS Gesamtumsatz FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN WHERE K.LAND = 'Germany' GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;")
    con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, K.LAND AS Land, SUM(B.UMSATZ) AS Gesamtumsatz FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND HAVING SUM(B.UMSATZ) > 2500;")
end

function event()
    select_query()
end