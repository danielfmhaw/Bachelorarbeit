local con = sysbench.sql.driver():connect()
package.path = package.path .. ";" .. debug.getinfo(1).source:match("@(.*)"):match("(.*/)") .. "../../../../Tools/Lua/?.lua"
local utils = require("utils")

local length = tonumber(os.getenv("LENGTH")) or 0

local num_rows = 700
local bestellungProKunde = 3

function delete_data()
    local delete_bestellung_query = "DELETE FROM BESTELLUNGMITVARCHAR;"
    local delete_kunden_query = "DELETE FROM KUNDENMITVARCHAR;"
    con:query("START TRANSACTION")
    con:query(delete_bestellung_query)
    con:query(delete_kunden_query)
    con:query("COMMIT")
end

-- Function to insert randomized data into KUNDENMITVARCHAR and BESTELLUNGMITVARCHAR
function insert_data()
    delete_data()
    for i = 1, num_rows do
        local name = utils.randomString(length) .. string.format("%d", i)
        local geburtstag = string.format("19%02d-%02d-%02d", math.random(50, 99), math.random(1, 12), math.random(1, 28))
        local adresse = string.format("Address_%d", i)
        local stadt = string.format("City_%d", math.random(1, 100))
        local postleitzahl = string.format("%05d", math.random(10000, 99999))
        local land = "Germany"
        local email = string.format("customer%d@example.com", i)
        local telefonnummer = string.format("+49157%07d", math.random(1000000, 9999999))

        -- Insert into KUNDENMITVARCHAR, ignoring duplicates
        local kunden_query = string.format([[
            INSERT IGNORE INTO KUNDENMITVARCHAR
            (NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
            VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
        ]], name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)

        con:query(kunden_query)

        for j = 1, bestellungProKunde do
            local bestellung_id = (i - 1) * bestellungProKunde + j
            local bestelldatum = string.format("2024-%02d-%02d", math.random(1, 12), math.random(1, 28))
            local artikel_id = math.random(1, 1000)
            local umsatz = math.random(100, 1000)

            -- Insert into BESTELLUNGMITVARCHAR, ignoring duplicates
            local bestellung_query = string.format([[
              INSERT IGNORE INTO BESTELLUNGMITVARCHAR
              (BESTELLUNG_ID, BESTELLDATUM, ARTIKEL_ID, FK_KUNDEN_NAME, UMSATZ)
              VALUES (%d,'%s', %d, '%s', %d);
            ]],bestellung_id, bestelldatum, artikel_id, name, umsatz)

            con:query(bestellung_query)
        end
    end
end

function event()
    insert_data()
end