local num_rows = 1000
local bestellungProKunde = 4

function delete_data()
    local delete_bestellung_query = "DELETE FROM BESTELLUNGMITID;"
    local delete_kunden_query = "DELETE FROM KUNDENMITID;"
    db_query("START TRANSACTION")
    db_query(delete_bestellung_query)
    db_query(delete_kunden_query)
    db_query("COMMIT")
end

function insert_data()
    delete_data()
    for i = 1, num_rows do
        local kunden_id = i -- define name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer
        local kunden_query = string.format([[
            INSERT IGNORE INTO KUNDENMITID
            (KUNDEN_ID, NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
            VALUES (%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
        ]], kunden_id, name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)
        db_query(kunden_query)

        for j = 1, bestellungProKunde do
            local bestellung_id = (i-1) * bestellungProKunde + j -- define bestelldatum, artikel_id, umsatz
            local bestellung_query = string.format([[
                INSERT IGNORE INTO BESTELLUNGMITID
                (BESTELLUNG_ID, BESTELLDATUM, ARTIKEL_ID, UMSATZ, FK_KUNDEN)
                VALUES (%d,'%s', %d, %d, %d);
            ]], bestellung_id, bestelldatum, artikel_id, umsatz, kunden_id)
            db_query(bestellung_query)
        end
    end
end

function event()
    insert_data()
end