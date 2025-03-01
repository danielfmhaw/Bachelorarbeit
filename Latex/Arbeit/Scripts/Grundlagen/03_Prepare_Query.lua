function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (...);
    ]]
    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNG (...);
    ]]

    db_query(create_kunden_query)
    db_query(create_bestellung_query)
    print("Tables KUNDEN und BESTELLUNG have been successfully created")
end