function select_desc_order()
    local desc_order_query = "SELECT * FROM KUNDEN ORDER BY KUNDEN_ID DESC;"
    db_query(desc_order_query)
end

function event()
    select_desc_order()
end
