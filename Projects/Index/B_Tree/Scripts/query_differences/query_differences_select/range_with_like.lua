function select_range_with_like()
    local range_with_like_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME LIKE 'M%' AND GEBURTSTAG < '1980-01-01';"
    db_query(range_with_like_query)
end

function event()
    select_range_with_like()
end
