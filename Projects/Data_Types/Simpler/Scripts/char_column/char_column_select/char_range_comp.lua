function select_simple_filter()
    local simple_filter_query = "SELECT * FROM KUNDEN WHERE KUNDEN_ID > '1234';"
    db_query(simple_filter_query)
end

function event()
    select_simple_filter()
end
