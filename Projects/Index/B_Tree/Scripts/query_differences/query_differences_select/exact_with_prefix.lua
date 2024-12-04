function select_exact_with_prefix()
    local exact_with_prefix_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME LIKE 'M%';"
    db_query(exact_with_prefix_query)
end

function event()
    select_exact_with_prefix()
end
