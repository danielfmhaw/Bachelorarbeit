local con = sysbench.sql.driver():connect()
local num_rows = 700
local bestellungProKunde = 3

function delete_data()
    local delete_bestellung_query = "DELETE FROM BESTELLUNGMITID;"
    local delete_kunden_query = "DELETE FROM KUNDENMITID;"
    con:query("START TRANSACTION")
    con:query(delete_bestellung_query)
    con:query(delete_kunden_query)
    con:query("COMMIT")
end
-- Function to insert randomized data into KUNDENMITID and BESTELLUNGMITID
function insert_data()
    delete_data()
    for i = 1, num_rows do
        local kunden_id = i
        local name = string.format("Kunde_%d", i)
        local geburtstag = string.format("19%02d-%02d-%02d", math.random(50, 99), math.random(1, 12), math.random(1, 28))
        local adresse = string.format("Address_%d", i)
        local stadt = string.format("City_%d", math.random(1, 100))
        local postleitzahl = string.format("%05d", math.random(10000, 99999))
        local land = "Germany"
        local email = string.format("customer%d@example.com", i)
        local telefonnummer = string.format("+49157%07d", math.random(1000000, 9999999))

        -- Insert into KUNDENMITID, ignoring duplicates
        local kunden_query = string.format([[
            INSERT IGNORE INTO KUNDENMITID
            (KUNDEN_ID, NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
            VALUES (%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
        ]], kunden_id, name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)

        -- Execute the customer insertion
        con:query(kunden_query)

        for j = 1, bestellungProKunde do
            local bestellung_id = (i-1) * bestellungProKunde + j
            local bestelldatum = string.format("2024-%02d-%02d", math.random(1, 12), math.random(1, 28))
            local artikel_id = math.random(1, 1000)
            local umsatz = math.random(100, 1000)
            -- Insert into BESTELLUNGMITID, referencing KUNDEN_ID
            local bestellung_query = string.format([[
                INSERT IGNORE INTO BESTELLUNGMITID
                (BESTELLUNG_ID, BESTELLDATUM, ARTIKEL_ID, FK_KUNDEN, UMSATZ)
                VALUES (%d,'%s', %d, %d, %d);
            ]], bestellung_id, bestelldatum, artikel_id, kunden_id, umsatz)

            con:query(bestellung_query)
        end
    end
end

function event()
    insert_data()
end