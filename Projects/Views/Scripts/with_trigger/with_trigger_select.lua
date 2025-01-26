function select_query()
    local select_kunden_mat_overview = "SELECT Count(*) FROM KUNDEN_MAT_OVERVIEW;"
    local select_germany_customers = "SELECT * FROM KUNDEN_MAT_OVERVIEW WHERE LAND = 'Germany';"
    local select_range_count = "SELECT * FROM KUNDEN_MAT_OVERVIEW WHERE ANZAHL_KUNDEN > 5000;"

    db_query(select_kunden_mat_overview)
    db_query(select_germany_customers)
    db_query(select_range_count)
end

function event()
    select_query()
end
