function select_query()
    local select_kunden_over_view = "SELECT * FROM KUNDEN_OVERVIEW;"
    db_query(select_kunden_over_view)
end

function event()
    select_query()
end
