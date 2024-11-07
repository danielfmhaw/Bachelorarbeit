local num_rows = 10000

function prepare()
    local create_kunden_query = [[
        CREATE TABLE IF NOT EXISTS KUNDENMITVARCHARLENGTH (
            NAME          VARCHAR(255) PRIMARY KEY,
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]]

    -- SQL query to create BESTELLUNGMITVARCHARLENGTH table
    local create_bestellung_query = [[
        CREATE TABLE IF NOT EXISTS BESTELLUNGMITVARCHARLENGTH (
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    VARCHAR(255) NOT NULL,
            UMSATZ       INT,
            PRIMARY KEY (BESTELLDATUM, ARTIKEL_ID, FK_KUNDEN),
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDENMITVARCHARLENGTH (NAME)
        );
    ]]

    -- Execute the table creation queries
    db_query(create_kunden_query)
    db_query(create_bestellung_query)

    -- Log message indicating tables have been created
    print("Tables KUNDENMITVARCHARLENGTH and BESTELLUNGMITVARCHARLENGTH have been successfully created.")

    insert_data()
end

local function randomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local randIndex = math.random(1, #charset)
        result = result .. charset:sub(randIndex, randIndex)
    end
    return result
end

-- Function to insert randomized data into KUNDENMITVARCHARLENGTH and BESTELLUNGMITVARCHARLENGTH
function insert_data()
    for i = 1, num_rows do
        -- Random data generation for KUNDENMITVARCHARLENGTH fields
        local name = randomString(64)
        local geburtstag = string.format("19%02d-%02d-%02d", math.random(50, 99), math.random(1, 12), math.random(1, 28))
        local adresse = string.format("Address_%d", i)
        local stadt = string.format("City_%d", math.random(1, 100))
        local postleitzahl = string.format("%05d", math.random(10000, 99999))
        local land = "Germany"
        local email = string.format("customer%d@example.com", i)
        local telefonnummer = string.format("+49157%07d", math.random(1000000, 9999999))

        -- Insert into KUNDENMITVARCHARLENGTH, ignoring duplicates
        local kunden_query = string.format([[
            INSERT IGNORE INTO KUNDENMITVARCHARLENGTH
            (NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
            VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');
        ]], name, geburtstag, adresse, stadt, postleitzahl, land, email, telefonnummer)

        -- Execute the customer insertion
        db_query(kunden_query)

        for j = 1, 5 do
            local bestelldatum = string.format("2024-%02d-%02d", math.random(1, 12), math.random(1, 28))
            local artikel_id = math.random(1, 1000)
            local umsatz = math.random(100, 1000)

            -- Insert into BESTELLUNGMITVARCHARLENGTH, ignoring duplicates
            local bestellung_query = string.format([[
                INSERT IGNORE INTO BESTELLUNGMITVARCHARLENGTH
                (BESTELLDATUM, ARTIKEL_ID, FK_KUNDEN, UMSATZ)
                VALUES ('%s', %d, '%s', %d);
            ]], bestelldatum, artikel_id, name, umsatz)

            -- Execute the order insertion
            db_query(bestellung_query)
        end
    end
end

-- Execute a JOIN query to calculate the sum of Umsatz per Stadt
function select_query()
    local join_query = [[
        SELECT k.STADT, SUM(b.UMSATZ) AS Total_Umsatz
        FROM KUNDENMITVARCHARLENGTH k
        JOIN BESTELLUNGMITVARCHARLENGTH b ON k.NAME = b.FK_KUNDEN
        GROUP BY k.STADT;
    ]]

    db_query(join_query)
end


function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDENMITVARCHARLENGTH;"
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNGMITVARCHARLENGTH;"

    db_query(drop_bestellung_query)
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end