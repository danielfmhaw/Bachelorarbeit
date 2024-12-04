function select_skip_columns()
    local skip_columns_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND GEBURTSTAG < '1980-01-01';"
    db_query(skip_columns_query)
end

function event()
    select_skip_columns()
end
