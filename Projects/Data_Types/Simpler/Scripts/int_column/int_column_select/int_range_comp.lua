local con = sysbench.sql.driver():connect()
function select_range_comp()
    con:query("SELECT * FROM KUNDEN WHERE KUNDEN_ID > 1234;")
end

function event()
    select_range_comp()
end
