local con = sysbench.sql.driver():connect()
function select_desc_sort()
    con:query("SELECT * FROM KUNDEN ORDER BY KUNDEN_ID DESC;")
end

function event()
    select_desc_sort()
end
