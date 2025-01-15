local size = os.getenv("TYP") or ""
size = size:gsub("([a-zA-Z]+)_(%d+)", "%2")
local priority = tonumber(os.getenv("LENGTH")) or 0
local typ = tostring(os.getenv("TYP")) or ""
local length = tonumber(priority) or tonumber(typ:match("%d+")) or 0
local num_rows = tonumber(os.getenv("NUM_ROWS")) or 0

local function randomString(length)
   local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
   local result = ""
   for i = 1, length do
       local randIndex = math.random(1, #charset)
       result = result .. charset:sub(randIndex, randIndex)
   end
   return result
end

function select_query()
    local query_city = "SELECT * FROM KUNDEN WHERE STADT = 'City_7' OR STADT = 'City_10';"
    local query_age = "SELECT NAME, GEBURTSTAG FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01';"
    local query_count_city = "SELECT STADT, COUNT(*) AS num_customers FROM KUNDEN GROUP BY STADT;"
    local query_order_name = "SELECT * FROM KUNDEN ORDER BY NAME DESC;"

    db_query(query_city)
    db_query(query_age)
    db_query(query_count_city)
    db_query(query_order_name)
end

-- Function to update data in the KUNDEN table
function update_data()
    local num_updates = math.random(0, num_rows/4)
    for i = 1, num_updates do
        local newlength = length + math.random(1, size-length)
        local name = randomString(newlength)
        local update_query = string.format([[
            UPDATE KUNDEN
            SET NAME = '%s'
            WHERE CAST(SUBSTRING(STADT, 6) AS UNSIGNED) >= 80
        ]], name)

        db_query(update_query)
    end
end


function event()
    select_query()
    if priority ~= 0 then
        update_data()
    end
end