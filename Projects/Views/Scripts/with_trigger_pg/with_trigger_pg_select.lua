local con = sysbench.sql.driver():connect()
function select_query()
    con:query("SELECT Jahr, SUM(Gesamtumsatz) AS UmsatzProJahr FROM KUNDEN_MAT_OVERVIEW GROUP BY Jahr;")
    con:query("SELECT * FROM KUNDEN_MAT_OVERVIEW WHERE Jahr = 2020;")
    con:query("SELECT * FROM KUNDEN_MAT_OVERVIEW WHERE Land = 'Germany';")
    con:query("SELECT * FROM KUNDEN_MAT_OVERVIEW WHERE Gesamtumsatz > 2500;")
end

function event()
    select_query()
end
