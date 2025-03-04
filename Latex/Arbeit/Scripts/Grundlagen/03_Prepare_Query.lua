local con = sysbench.sql.driver():connect()
function prepare()
    local create_kunden_query = [[
        CREATE TABLE KUNDEN (...);
    ]]
    local create_bestellung_query = [[
        CREATE TABLE BESTELLUNG (...);
    ]]

    con:query(create_kunden_query)
    con:query(create_bestellung_query)
    print("Tables KUNDEN und BESTELLUNG have been successfully created")
end