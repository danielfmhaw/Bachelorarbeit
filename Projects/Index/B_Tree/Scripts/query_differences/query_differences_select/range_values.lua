local con = sysbench.sql.driver():connect()
function select_range_values()
    con:query("SELECT * FROM KUNDEN WHERE NAME BETWEEN 'Müller' AND 'Schulz';")
end

function event()
    select_range_values()
end
