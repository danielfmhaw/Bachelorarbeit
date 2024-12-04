function select_leftmost_prefix()
    local leftmost_prefix_query = "SELECT * FROM KUNDEN WHERE NAME = 'Müller';"
    db_query(leftmost_prefix_query)
end

function event()
    select_leftmost_prefix()
end
