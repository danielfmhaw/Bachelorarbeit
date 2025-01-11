function select_query()
    local query_count = "SELECT COUNT(*) FROM KUNDEN;"
    local query_name_order = "SELECT * FROM KUNDEN ORDER BY NAME;"

    db_query(query_count)
    db_query(query_name_order)
end

function event()
    select_query()
end
