local num_rows = 10000

function prepare()
    -- SQL query to create the KUNDENMITID table without auto-increment for KUNDEN_ID
    local create_kunden_query = [[
        CREATE TABLE IF NOT EXISTS KUNDENMITID (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255) UNIQUE,
            TELEFONNUMMER VARCHAR(20)
        );
    ]]

    -- SQL query to create the BESTELLUNGMITID table
    local create_bestellung_query = [[
        CREATE TABLE IF NOT EXISTS BESTELLUNGMITID (
            BESTELLUNG_ID INT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    INT NOT NULL,
            UMSATZ       INT,
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDENMITID (KUNDEN_ID)
        );
    ]]

    -- Execute the table creation queries
    db_query(create_kunden_query)
    db_query(create_bestellung_query)
    print("Tables KUNDENMITID and BESTELLUNGMITID have been successfully created.")

    insert_data()
end

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

        for j = 1, 5 do
            local bestellung_id = i + j
            local bestelldatum = string.format("2024-%02d-%02d", math.random(1, 12), math.random(1, 28))
            local artikel_id = math.random(1, 1000)
            local umsatz = math.random(100, 1000)
            -- Insert into BESTELLUNGMITID, referencing KUNDEN_ID
            local bestellung_query = string.format([[
                INSERT IGNORE INTO BESTELLUNGMITID
                (BESTELLUNG_ID, BESTELLDATUM, ARTIKEL_ID, FK_KUNDEN, UMSATZ)
                VALUES (%d,'%s', %d, %d, %d);
            ]], bestellung_id, bestelldatum, artikel_id, kunden_id, umsatz)

            db_query(bestellung_query)
        end
    end
end

-- Function to execute a JOIN query to calculate total Umsatz per Stadt
function select_query()
    local join_query = [[
        SELECT k.STADT, SUM(b.UMSATZ) AS Total_Umsatz
        FROM KUNDENMITID k
        JOIN BESTELLUNGMITID b ON k.KUNDEN_ID = b.FK_KUNDEN
        GROUP BY k.STADT;
    ]]
    db_query(join_query)
end

-- Cleanup function to drop tables
function cleanup()
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNGMITID;"
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDENMITID;"

    db_query(drop_bestellung_query)
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end