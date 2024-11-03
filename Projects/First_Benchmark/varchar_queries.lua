local num_rows = 10000

function prepare()
    local create_kunden_query = [[
        CREATE TABLE IF NOT EXISTS KUNDENMITVARCHAR (
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

    -- SQL query to create BESTELLUNGMITVARCHAR table
    local create_bestellung_query = [[
        CREATE TABLE IF NOT EXISTS BESTELLUNGMITVARCHAR (
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            FK_KUNDEN    VARCHAR(255) NOT NULL,
            UMSATZ       INT,
            PRIMARY KEY (BESTELLDATUM, ARTIKEL_ID, FK_KUNDEN),
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDENMITVARCHAR (NAME)
        );
    ]]

    -- Execute the table creation queries
    db_query(create_kunden_query)
    db_query(create_bestellung_query)

    -- Log message indicating tables have been created
    print("Tables KUNDENMITVARCHAR and BESTELLUNGMITVARCHAR have been successfully created.")
end

-- Function to insert randomized data into KUNDENMITVARCHAR and BESTELLUNGMITVARCHAR
function insert_data()
    for i = 1, num_rows do
        -- Random data generation for KUNDENMITVARCHAR fields
        local name = string.format("Customer_%d", i)
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

        -- Execute the customer insertion
        db_query(kunden_query)

        -- Insert randomized orders into BESTELLUNGMITVARCHAR for each customer
        local order_count = math.random(1, 5)  -- Random number of orders per customer
        for j = 1, order_count do
            local bestelldatum = string.format("2024-%02d-%02d", math.random(1, 12), math.random(1, 28))
            local artikel_id = math.random(1, 1000)
            local umsatz = math.random(100, 1000)

            -- Insert into BESTELLUNGMITVARCHAR, ignoring duplicates
            local bestellung_query = string.format([[
                INSERT IGNORE INTO BESTELLUNGMITVARCHAR
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
        FROM KUNDENMITVARCHAR k
        JOIN BESTELLUNGMITVARCHAR b ON k.NAME = b.FK_KUNDEN
        GROUP BY k.STADT;
    ]]

    db_query(join_query)
end


function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDENMITVARCHAR;"
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNGMITVARCHAR;"

    db_query(drop_bestellung_query)
    db_query(drop_kunden_query)
    print("Cleanup sucessfully done")
end

function event()
    insert_data()
    select_query()
end