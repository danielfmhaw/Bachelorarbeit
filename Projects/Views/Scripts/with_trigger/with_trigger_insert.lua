local num_rows = tonumber(os.getenv("LENGTH")) or 0

-- List of countries
local countries = {
    "China", "India", "United States", "Indonesia", "Pakistan",
    "Brazil", "Nigeria", "Bangladesh", "Russia", "Mexico",
    "Japan", "Ethiopia", "Philippines", "Egypt", "Vietnam",
    "DR Congo", "Turkey", "Iran", "Germany", "Thailand",
    "Portugal"
}

function delete_data()
    local delete_kunden_query = "DELETE FROM KUNDEN;"
    db_query("START TRANSACTION")
    db_query(delete_kunden_query)
    db_query("COMMIT")
end

-- Function to insert randomized data into KUNDEN
function insert_data()
    delete_data()
    for i = 1, num_rows do
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
            (NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
            VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
        ]], name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)
        db_query(kunden_query)
    end
end

function event()
    insert_data()
end
