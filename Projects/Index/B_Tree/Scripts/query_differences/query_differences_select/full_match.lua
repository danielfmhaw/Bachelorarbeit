local con = sysbench.sql.driver():connect()
function select_full_match()
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME = 'Max' AND GEBURTSTAG = '1960-01-01';")
end

function event()
    select_full_match()
end
