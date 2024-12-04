function select_not_leftmost()
    local not_leftmost_query = "SELECT * FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01';"
    db_query(not_leftmost_query)
end

function event()
    select_not_leftmost()
end
