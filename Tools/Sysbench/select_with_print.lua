package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")

local con = sysbench.sql.driver():connect()
local counts_printed = false

function select_query()
    if not counts_printed then
        local kunden_count_result = con:query("SELECT COUNT(*) FROM KUNDEN;")
        local kunden_count = (kunden_count_result and kunden_count_result.nrows > 0) and kunden_count_result:fetch_row()[1] or 0

        local bestellung_count_result = con:query("SELECT COUNT(*) FROM BESTELLUNG;")
        local bestellung_count = (bestellung_count_result and bestellung_count_result.nrows > 0) and bestellung_count_result:fetch_row()[1] or 0

        io.stderr:write(string.format("KUNDEN has %d items, BESTELLUNG has %d items\n", kunden_count, bestellung_count))
        utils.print_results(con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, SUM(B.UMSATZ) AS UmsatzProJahr FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM);"))
        counts_printed = true
    else
        con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, SUM(B.UMSATZ) AS UmsatzProJahr FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM);")
    end

    con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, K.LAND AS Land, SUM(B.UMSATZ) AS Gesamtumsatz FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN WHERE EXTRACT(YEAR FROM B.BESTELLDATUM) = 2020 GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;")
    con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, K.LAND AS Land, SUM(B.UMSATZ) AS Gesamtumsatz FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN WHERE K.LAND = 'Germany' GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND;")
    con:query("SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr, K.LAND AS Land, SUM(B.UMSATZ) AS Gesamtumsatz FROM KUNDEN K JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.LAND HAVING SUM(B.UMSATZ) > 100000;")
end

function event()
    select_query()
end