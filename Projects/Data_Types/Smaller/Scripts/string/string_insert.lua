local priority = tonumber(os.getenv("LENGTH"))
local typ = tostring(os.getenv("TYP")) or ""
local length = tonumber(priority) or tonumber(typ:match("%d+")) or 0
local num_rows = tonumber(os.getenv("NUM_ROWS")) or 0

-- Function to generate a random string of a given length
local function randomString(length)
   local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
   local result = ""
   for i = 1, length do
       local randIndex = math.random(1, #charset)
       result = result .. charset:sub(randIndex, randIndex)
   end
   return result
end

function delete_data()
   local delete_kunden_query = "DELETE FROM KUNDEN;"
   db_query("START TRANSACTION")
   db_query(delete_kunden_query)
   db_query("COMMIT")
end

-- Function to insert randomized data into KUNDEN
function insert_data()
   print("daniel",length)
   delete_data()
   for i = 1, num_rows do
       local name = randomString(length) .. string.format("%d", i)
       local geburtstag = string.format("19%02d-%02d-%02d", math.random(50, 99), math.random(1, 12), math.random(1, 28))
       local adresse = string.format("Address_%d", i)
       local stadt = string.format("City_%d", math.random(1, 100))
       local postleitzahl = string.format("%05d", math.random(10000, 99999))
       local land = "Germany"
       local email = string.format("customer%d@example.com", i)
       local telefonnummer = string.format("+49157%07d", math.random(1000000, 9999999))

       -- Insert into KUNDEN, ignoring duplicates
       local kunden_query = string.format([[
           INSERT IGNORE INTO KUNDEN
           (NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
           VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
       ]], name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)

       db_query(kunden_query)
   end
end

function event()
   insert_data()
end
