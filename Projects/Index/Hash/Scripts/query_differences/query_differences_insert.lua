local con = sysbench.sql.driver():connect()
local num_rows = 3000

local last_names = {
    "Müller", "Schmidt", "Schneider", "Fischer", "Weber", "Meier", "Wagner", "Becker", "Hoffmann", "Schulz", "Zimmermann", "Schwarz", "Koch", "Richter", "Bauer"
}

local first_names = {
    "Max", "Anna", "John", "Laura", "David", "Marie", "Paul", "Sophia", "Lukas", "Mia", "Leon", "Emma", "Niklas", "Lena", "Felix"
}

function delete_data()
    local delete_kunden_query = "DELETE FROM KUNDEN;"
    con:query("START TRANSACTION")
    con:query(delete_kunden_query)
    con:query("COMMIT")
end

-- Function to insert randomized data into KUNDEN
function insert_data()
    delete_data()
    for i = 1, num_rows do
        local kunden_id = i
        local name = last_names[math.random(1, #last_names)]
        local vorname = first_names[math.random(1, #first_names)]
        local geburtstag = string.format("19%02d-%02d-%02d", math.random(50, 99), math.random(1, 12), math.random(1, 28))
        local adresse = string.format("Address_%d", i)
        local stadt = string.format("City_%d", math.random(1, 100))
        local postleitzahl = string.format("%05d", math.random(10000, 99999))
        local land = "Germany"
        local email = string.format("customer%d@example.com", i)
        local telefonnummer = string.format("+49157%07d", math.random(1000000, 9999999))

        local kunden_query = string.format([[
            INSERT IGNORE INTO KUNDEN
            (KUNDEN_ID, NAME, VORNAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
            VALUES (%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
        ]], kunden_id, name, vorname, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)
        con:query(kunden_query)
    end
end

function event()
    insert_data()
end
