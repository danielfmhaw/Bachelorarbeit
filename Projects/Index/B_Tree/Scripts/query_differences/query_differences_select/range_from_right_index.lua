function select_query()
    local right_range = "SELECT * FROM KUNDEN WHERE POSTLEITZAHL = '22144' AND GEBURTSTAG < '1980-01-01';"
    db_query(right_range)
end

function event()
    select_query()
end