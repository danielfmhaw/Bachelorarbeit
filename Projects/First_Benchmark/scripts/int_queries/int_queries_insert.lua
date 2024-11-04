local num_rows = 10000

-- Function to insert randomized data into KUNDENMITID and BESTELLUNGMITID
function insert_data()
    for i = 1, num_rows do
        local kunden_id = i
        local name = string.format("Customer_%d", i)
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
        db_query(kunden_query)

        -- Insert randomized orders into BESTELLUNGMITID for each customer
        local order_count = math.random(1, 5)
        for j = 1, order_count do
            local bestelldatum = string.format("2024-%02d-%02d", math.random(1, 12), math.random(1, 28))
            local artikel_id = math.random(1, 1000)
            local umsatz = math.random(100, 1000)

            -- Insert into BESTELLUNGMITID, referencing KUNDEN_ID
            local bestellung_query = string.format([[
                INSERT IGNORE INTO BESTELLUNGMITID
                (BESTELLDATUM, ARTIKEL_ID, FK_KUNDEN, UMSATZ)
                VALUES ('%s', %d, %d, %d);
            ]], bestelldatum, artikel_id, kunden_id, umsatz)

            db_query(bestellung_query)
        end
    end
end

function event()
    insert_data()
end