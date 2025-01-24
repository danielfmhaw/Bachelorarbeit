function select_query()
    local select_all_kunden = "SELECT * FROM KUNDEN;"
    db_query(select_all_kunden)
end

function event()
    select_query()
end
