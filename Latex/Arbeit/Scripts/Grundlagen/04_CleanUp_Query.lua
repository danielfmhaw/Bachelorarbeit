function cleanup()
    local drop_kunden_query = "DROP TABLE IF EXISTS KUNDEN;"
    local drop_bestellung_query = "DROP TABLE IF EXISTS BESTELLUNG;"

    db_query(drop_bestellung_query)
    db_query(drop_kunden_query)
    print("Cleanup successfully done")
end