local con = sysbench.sql.driver():connect()
function select_column_prefix()
    con:query("SELECT * FROM KUNDEN WHERE NAME LIKE 'M%';")
end

function event()
    select_column_prefix()
end
