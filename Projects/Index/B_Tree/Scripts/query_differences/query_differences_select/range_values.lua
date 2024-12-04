function select_range_values()
    local range_query = "SELECT * FROM KUNDEN WHERE NAME BETWEEN 'Müller' AND 'Schulz';"
    db_query(range_query)
end

function event()
    select_range_values()
end
