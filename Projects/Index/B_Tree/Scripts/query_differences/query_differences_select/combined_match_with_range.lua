function select_combined_match_with_range()
    db_query(combined_range_query)
    local combined_range_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME = 'Max' AND GEBURTSTAG < '1980-01-01';"
end

function event()
    select_combined_match_with_range()
end
