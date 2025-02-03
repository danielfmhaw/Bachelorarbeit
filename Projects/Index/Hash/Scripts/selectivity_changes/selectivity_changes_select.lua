local con = sysbench.sql.driver():connect()
function select_query()
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Kunde_1' AND GEBURTSTAG < '1980-01-01';")
end

function event()
    select_query()
end
