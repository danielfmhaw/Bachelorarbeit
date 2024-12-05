function select_query()
    local query_name = "SELECT * FROM KUNDEN WHERE NAME = 'Kunde_1';"
    db_query(query_name)
end

function event()
    select_query()
end
