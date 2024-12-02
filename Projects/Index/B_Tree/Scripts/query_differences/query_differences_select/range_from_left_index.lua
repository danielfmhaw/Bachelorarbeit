function select_query()
    local left_range = "SELECT * FROM KUNDEN WHERE STADT = 'City_7' AND GEBURTSTAG < '1980-01-01';"
    db_query(left_range)
end

function event()
    select_query()
end
