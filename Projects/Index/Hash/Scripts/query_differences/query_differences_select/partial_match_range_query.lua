local con = sysbench.sql.driver():connect()
function select_partial_match_range_query()
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME BETWEEN 'David' AND 'Laura';")
end

function event()
    select_partial_match_range_query()
end
