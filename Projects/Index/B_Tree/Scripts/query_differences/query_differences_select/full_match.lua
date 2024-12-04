function select_full_match()
    local full_match_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME = 'Max' AND GEBURTSTAG = '1960-01-01';"
    db_query(full_match_query)
end

function event()
    select_full_match()
end
