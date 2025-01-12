--WHERE NAME IS NULL
function select_query()
    local query_order_name = "SELECT * FROM KUNDEN ORDER BY NAME ASC;"
    local query_order_email = "SELECT * FROM KUNDEN ORDER BY EMAIL ASC;"
    local query_group_land = "SELECT LAND, COUNT(*) FROM KUNDEN GROUP BY LAND;"
    local query_group_city = "SELECT STADT, COUNT(*) FROM KUNDEN GROUP BY STADT;"
    local query_email = "SELECT * FROM KUNDEN WHERE EMAIL = 'customer100@example.com';"
    local query_name = "SELECT * FROM KUNDEN WHERE ADRESSE = 'Adresse_100';"
    local query_count_cust = "SELECT COUNT(*) FROM KUNDEN WHERE STADT LIKE 'City_%';"
    local query_count_null = "SELECT STADT,COUNT(*) FROM KUNDEN GROUP BY STADT;"

    db_query(query_order_name)
    db_query(query_order_email)
    db_query(query_group_land)
    db_query(query_email)
    db_query(query_name)
    db_query(query_count_cust)
    db_query(query_group_city)
    db_query(query_count_null)
end

function event()
    select_query()
end