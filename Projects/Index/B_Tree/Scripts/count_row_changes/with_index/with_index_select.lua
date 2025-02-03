local con = sysbench.sql.driver():connect()
function select_query()
    con:query("SELECT * FROM KUNDEN WHERE STADT = 'City_7' OR STADT = 'City_10';")
    con:query("SELECT NAME, GEBURTSTAG FROM KUNDEN WHERE GEBURTSTAG < '1980-01-01';")
    con:query("SELECT STADT, COUNT(*) AS num_customers FROM KUNDEN GROUP BY STADT;")
end

function event()
    select_query()
end
