function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDENMITID (
            ....
        );
    ]]
    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNGMITID (
            ...
        );
    ]]

    db_query(create_kunden_query)
    db_query(create_bestellung_query)
    print("Tables KUNDENMITID and BESTELLUNGMITID have been successfully created.")
end