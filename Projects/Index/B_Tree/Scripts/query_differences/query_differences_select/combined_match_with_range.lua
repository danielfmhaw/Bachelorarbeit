local con = sysbench.sql.driver():connect()
function select_combined_match_with_range()
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME = 'Max' AND GEBURTSTAG < '1980-01-01';")
end

function event()
    select_combined_match_with_range()
end
