local con = sysbench.sql.driver():connect()
function select_not_leftmost()
    con:query("SELECT * FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01';")
end

function event()
    select_not_leftmost()
end
