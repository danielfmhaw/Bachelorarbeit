function prepare()
    -- Create KUNDEN table if it doesn't exist
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (
            KUNDEN_ID     SERIAL PRIMARY KEY,
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

    -- Create the materialized view that aggregates the data for fast access
    local create_materialized_view_query = [[
        CREATE MATERIALIZED VIEW IF NOT EXISTS KUNDEN_MAT_OVERVIEW AS
        SELECT
            LAND,
            COUNT(*) AS ANZAHL_KUNDEN
        FROM KUNDEN
        WHERE LAND IS NOT NULL
          AND EXTRACT(YEAR FROM AGE(GEBURTSTAG)) < 50
        GROUP BY LAND;
    ]]

    -- Execute the queries to create the tables, materialized view, and refresh function
    db_query(create_kunden_query)
    db_query(create_materialized_view_query)

    print("Table 'KUNDEN' and Materialized View 'KUNDEN_MAT_OVERVIEW' have been successfully created.")
end

function cleanup()
    -- Drop the materialized view, table, and refresh function
    local drop_refresh_function_query = "DROP FUNCTION IF EXISTS refresh_kunden_mat_overview;"
    local drop_materialized_view_query = "DROP MATERIALIZED VIEW IF EXISTS KUNDEN_MAT_OVERVIEW;"
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"

    db_query(drop_refresh_function_query)
    db_query(drop_materialized_view_query)
    db_query(drop_kunden_query)

    print("Cleanup successfully done.")
end