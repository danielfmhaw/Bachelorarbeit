function select_count_name_divide_by_3()
    local count_name_divide_by_3_query = "SELECT COUNT(*) AS Anzahl FROM KUNDEN WHERE CAST(SUBSTRING_INDEX(name, '_', -1) AS UNSIGNED) % 3 = 0;"
    db_query(count_name_divide_by_3_query)
end

function event()
    select_count_name_divide_by_3()
end
