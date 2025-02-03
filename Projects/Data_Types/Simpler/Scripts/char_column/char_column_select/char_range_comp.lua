local con = sysbench.sql.driver():connect()
function select_simple_filter()
    con:query("SELECT * FROM KUNDEN WHERE KUNDEN_ID > '1234';")
end

function event()
    select_simple_filter()
end
