local con = sysbench.sql.driver():connect()
function select_range_with_like()
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME LIKE 'M%' AND GEBURTSTAG < '1980-01-01';")
end

function event()
    select_range_with_like()
end
