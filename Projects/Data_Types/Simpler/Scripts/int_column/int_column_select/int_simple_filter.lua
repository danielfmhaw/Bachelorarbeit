function select_simple_filter()
    local simple_filter_query = "SELECT * FROM KUNDEN WHERE KUNDEN_ID = '12345';"
    db_query(simple_filter_query)
end

function event()
    select_simple_filter()
end
