function select_column_prefix()
    local column_prefix_query = "SELECT * FROM KUNDEN WHERE NAME LIKE 'M%';"
    db_query(column_prefix_query)
end

function event()
    select_column_prefix()
end
