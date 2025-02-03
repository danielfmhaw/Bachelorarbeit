local con = sysbench.sql.driver():connect()
function select_desc_order()
    con:query("SELECT * FROM KUNDEN ORDER BY KUNDEN_ID DESC;")
end

function event()
    select_desc_order()
end
