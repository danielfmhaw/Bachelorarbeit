local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")
local explain_executed = false

function select_query()
    if not explain_executed then
        utils.print_results(con, "SELECT COUNT(*) FROM KUNDEN;")
        explain_executed = true
    end
    con:query("SELECT * FROM KUNDEN ORDER BY NAME ASC;")
    con:query("SELECT * FROM KUNDEN ORDER BY EMAIL ASC;")
    con:query("SELECT LAND, COUNT(*) FROM KUNDEN GROUP BY LAND;")
    con:query("SELECT STADT, COUNT(*) FROM KUNDEN GROUP BY STADT;")
    con:query("SELECT * FROM KUNDEN WHERE EMAIL = 'customer100@example.com';")
    con:query("SELECT * FROM KUNDEN WHERE ADRESSE = 'Adresse_100';")
    con:query("SELECT COUNT(*) FROM KUNDEN WHERE STADT LIKE 'City_%';")
    con:query("SELECT STADT,COUNT(*) FROM KUNDEN GROUP BY STADT;")
end

function event()
    select_query()
end