function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     INT AUTO_INCREMENT PRIMARY KEY,
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

    local create_materialized_view_query = [[
        CREATE TABLE KUNDEN_MAT_OVERVIEW AS
        SELECT 
            LAND,
            COUNT(*) AS ANZAHL_KUNDEN
        FROM KUNDEN
        WHERE LAND IS NOT NULL
          AND TIMESTAMPDIFF(YEAR, GEBURTSTAG, CURDATE()) < 50
        GROUP BY LAND;
    ]]

    local create_insert_trigger_query = [[
        CREATE TRIGGER UPDATE_KUNDEN_MAT_OVERVIEW_AFTER_INSERT
            AFTER INSERT ON KUNDEN
            FOR EACH ROW
        BEGIN
            UPDATE KUNDEN_MAT_OVERVIEW
            SET ANZAHL_KUNDEN = ANZAHL_KUNDEN + 1
            WHERE LAND = NEW.LAND AND LAND IS NOT NULL;

            INSERT INTO KUNDEN_MAT_OVERVIEW (LAND, ANZAHL_KUNDEN)
            SELECT NEW.LAND, 1
            WHERE NOT EXISTS (
                SELECT 1
                FROM KUNDEN_MAT_OVERVIEW
                WHERE LAND = NEW.LAND AND LAND IS NOT NULL
            );
        END;
    ]]

    local create_delete_trigger_query = [[
        CREATE TRIGGER UPDATE_KUNDEN_MAT_OVERVIEW_AFTER_DELETE
            AFTER DELETE ON KUNDEN
            FOR EACH ROW
        BEGIN
            UPDATE KUNDEN_MAT_OVERVIEW
            SET ANZAHL_KUNDEN = ANZAHL_KUNDEN - 1
            WHERE LAND = OLD.LAND AND LAND IS NOT NULL;

            DELETE FROM KUNDEN_MAT_OVERVIEW
            WHERE LAND = OLD.LAND AND ANZAHL_KUNDEN <= 0;
        END;
    ]]
    db_query(create_kunden_query)
    db_query(create_materialized_view_query)
    db_query(create_insert_trigger_query)
    db_query(create_delete_trigger_query)
    print("Table 'KUNDEN', Table 'KUNDEN_MAT_OVERVIEW' and Triggers have been successfully created.")
end

function cleanup()
    local drop_trigger_insert = "DROP TRIGGER IF EXISTS UPDATE_KUNDEN_MAT_OVERVIEW_AFTER_INSERT;"
    local drop_trigger_delete = "DROP TRIGGER IF EXISTS UPDATE_KUNDEN_MAT_OVERVIEW_AFTER_DELETE"
    local drop_materialized_view_query = "DROP TABLE IF EXISTS KUNDEN_MAT_OVERVIEW;"
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    db_query(drop_trigger_insert)
    db_query(drop_trigger_delete)
    db_query(drop_materialized_view_query)
    db_query(drop_kunden_query)
    print("Cleanup successfully done.")
end