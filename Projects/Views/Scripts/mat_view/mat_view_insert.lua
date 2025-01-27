local con = sysbench.sql.driver():connect()
local num_rows = 400
local bestellungProKunde = 2
local refresh = tostring(os.getenv("REFRESH")) or ""

-- List of countries
local countries = {
    "China", "India", "United States", "Indonesia", "Pakistan",
    "Brazil", "Nigeria", "Bangladesh", "Russia", "Mexico",
    "Japan", "Ethiopia", "Philippines", "Egypt", "Vietnam",
    "DR Congo", "Turkey", "Iran", "Germany", "Thailand",
    "Portugal"
}

function refresh_mat_view()
   local refresh_materialized_view_query = "REFRESH MATERIALIZED VIEW KUNDEN_MAT_OVERVIEW;"
   con:query(refresh_materialized_view_query)
end

function delete_data()
    local delete_bestellung_query = "DELETE FROM BESTELLUNG;"
    local delete_kunden_query = "DELETE FROM KUNDEN;"
    con:query("START TRANSACTION")
    con:query(delete_bestellung_query)
    con:query(delete_kunden_query)
    con:query("COMMIT")
end

-- Function to insert randomized data into KUNDEN
function insert_data()
    delete_data()
    for i = 1, num_rows do
        local kunden_id = i
        local name = string.format("Kunde_%d", i)
        local geburtstag = string.format("19%02d-%02d-%02d", math.random(50, 99), math.random(1, 12), math.random(1, 28))
        local adresse = string.format("Address_%d", i)
        local stadt = string.format("City_%d", math.random(1, 100))
        local postleitzahl = string.format("%05d", math.random(10000, 99999))
        local land = countries[math.random(#countries)]
        local email = string.format("customer%d@example.com", i)
        local telefonnummer = string.format("+49157%07d", math.random(1000000, 9999999))

        local kunden_query = string.format([[
            INSERT INTO KUNDEN
            (KUNDEN_ID, NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
            VALUES (%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
        ]], kunden_id, name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)
        con:query(kunden_query)

        for j = 1, bestellungProKunde do
            local bestelldatum = string.format("%d-%02d-%02d", math.random(2018, 2024), math.random(1, 12), math.random(1, 28))
            local artikel_id = math.random(1, 1000)
            local umsatz = math.random(100, 1000)

            local bestellung_query = string.format([[
                INSERT INTO BESTELLUNG
                (BESTELLDATUM, ARTIKEL_ID, FK_KUNDEN, UMSATZ)
                VALUES ('%s', %d, %d, %d);
            ]], bestelldatum, artikel_id, kunden_id, umsatz)

            con:query(bestellung_query)
        end
        if refresh == "every" then
            refresh_mat_view()
        end
    end
    if refresh == "once" then
        refresh_mat_view()
    end
end

function event()
    insert_data()
end