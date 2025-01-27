local con = sysbench.sql.driver():connect()
function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     INT PRIMARY KEY,
            NAME          VARCHAR(255),
            GEBURTSTAG    DATE,
            ADRESSE       VARCHAR(255),
            STADT         VARCHAR(100),
            POSTLEITZAHL  VARCHAR(10),
            LAND          VARCHAR(100),
            EMAIL         VARCHAR(255),
            TELEFONNUMMER VARCHAR(20)
        );
    ]]

    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNG (
            BESTELLUNG_ID INT AUTO_INCREMENT PRIMARY KEY,
            BESTELLDATUM DATE,
            ARTIKEL_ID   INT,
            UMSATZ       INT,
            FK_KUNDEN    INT NOT NULL,
            FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDEN (KUNDEN_ID) ON DELETE CASCADE
        );
    ]]

    local create_materialized_view_query = [[
        CREATE TABLE KUNDEN_MAT_OVERVIEW(
            JAHR         INT,
            LAND         VARCHAR(100),
            GESAMTUMSATZ INT,
            PRIMARY KEY (JAHR,LAND)
        );
    ]]

    local create_insert_bestellung_trigger_query = [[
        CREATE TRIGGER UPDATE_BESTELLUNG_MAT_OVERVIEW_AFTER_INSERT
        AFTER INSERT ON BESTELLUNG
        FOR EACH ROW
        BEGIN
            DECLARE v_land VARCHAR(255);
            DECLARE v_jahr INT;
            SELECT LAND INTO v_land FROM KUNDEN WHERE KUNDEN_ID = NEW.FK_KUNDEN;
            SELECT EXTRACT(YEAR FROM NEW.BESTELLDATUM) INTO v_jahr;

            IF EXISTS (
                SELECT 1
                FROM KUNDEN_MAT_OVERVIEW
                WHERE LAND = v_land AND JAHR = v_jahr
            ) THEN
                UPDATE KUNDEN_MAT_OVERVIEW
                SET GESAMTUMSATZ = GESAMTUMSATZ + NEW.UMSATZ
                WHERE LAND = v_land AND JAHR = v_jahr;
            ELSE
                INSERT INTO KUNDEN_MAT_OVERVIEW (JAHR, LAND, GESAMTUMSATZ)
                VALUES (v_jahr, v_land, NEW.UMSATZ);
            END IF;
        END;
    ]]

    local create_delete_bestellung_trigger_query = [[
        CREATE TRIGGER UPDATE_BESTELLUNG_MAT_OVERVIEW_AFTER_DELETE
        AFTER DELETE ON BESTELLUNG
        FOR EACH ROW
        BEGIN
            DECLARE v_land VARCHAR(255);
            DECLARE v_jahr INT;
            SELECT LAND INTO v_land FROM KUNDEN WHERE KUNDEN_ID = OLD.FK_KUNDEN;
            SELECT EXTRACT(YEAR FROM OLD.BESTELLDATUM) INTO v_jahr;

            IF EXISTS (
                SELECT 1
                FROM KUNDEN_MAT_OVERVIEW
                WHERE LAND = v_land AND JAHR = v_jahr
            ) THEN
                UPDATE KUNDEN_MAT_OVERVIEW
                SET GESAMTUMSATZ = GESAMTUMSATZ - OLD.UMSATZ
                WHERE LAND = v_land AND JAHR = v_jahr;
            END IF;
        END;
    ]]

    con:query(create_kunden_query)
    con:query(create_bestellung_query)
    con:query(create_materialized_view_query)
    con:query(create_insert_bestellung_trigger_query)
    con:query(create_delete_bestellung_trigger_query)
    print("Table 'KUNDEN', Table 'BESTELLUNG', Table 'KUNDEN_MAT_OVERVIEW' and Triggers have been successfully created.")
end

function cleanup()
    con:query("DROP TRIGGER IF EXISTS UPDATE_BESTELLUNG_MAT_OVERVIEW_AFTER_INSERT;")
    con:query("DROP TRIGGER IF EXISTS UPDATE_BESTELLUNG_MAT_OVERVIEW_AFTER_DELETE;")
    con:query("DROP TABLE IF EXISTS KUNDEN_MAT_OVERVIEW;")
    con:query("DROP TABLE IF EXISTS BESTELLUNG;")
    con:query("DROP TABLE IF EXISTS KUNDEN;")
    print("Cleanup successfully done.")
end