function select_count_null()
    local count_null_query = "SELECT COUNT(*) as Anzahl FROM KUNDEN WHERE KUNDEN_ID is NULL;"
    db_query(count_null_query)
end

function event()
    select_count_null()
end
