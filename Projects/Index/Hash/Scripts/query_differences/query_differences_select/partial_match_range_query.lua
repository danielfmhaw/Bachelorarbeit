local con = sysbench.sql.driver():connect()
function select_combined_match_with_range()
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME BETWEEN 'David' AND 'Laura';")
end

function event()
    select_combined_match_with_range()
end
