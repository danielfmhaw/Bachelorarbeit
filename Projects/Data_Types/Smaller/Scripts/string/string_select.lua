local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../../Tools/Lua/?.lua"
local utils = require("utils")

local size = os.getenv("TYP") or ""
size = size:gsub("([a-zA-Z]+)_(%d+)", "%2")
local priority = tonumber(os.getenv("LENGTH")) or 0
local typ = tostring(os.getenv("TYP")) or ""
local length = tonumber(priority) or tonumber(typ:match("%d+")) or 0
local num_rows = tonumber(os.getenv("NUM_ROWS")) or 0

function select_query()
    con:query("SELECT * FROM KUNDEN WHERE STADT = 'City_7' OR STADT = 'City_10';")
    con:query("SELECT NAME, GEBURTSTAG FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01';")
    con:query("SELECT STADT, COUNT(*) AS num_customers FROM KUNDEN GROUP BY STADT;")
    con:query("SELECT * FROM KUNDEN ORDER BY NAME DESC;")
end

-- Function to update data in the KUNDEN table
function update_data()
    local num_updates = math.random(0, num_rows/4)
    for i = 1, num_updates do
        local newlength = length + math.random(1, size-length)
        local name = utils.randomString(newlength)
        local update_query = string.format([[
            UPDATE KUNDEN
            SET NAME = '%s'
            WHERE CAST(SUBSTRING(STADT, 6) AS UNSIGNED) >= 80
        ]], name)

        con:query(update_query)
    end
end


function event()
    select_query()
    if priority ~= 0 then
        update_data()
    end
end