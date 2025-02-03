local con = sysbench.sql.driver():connect()
function select_skip_columns()
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND GEBURTSTAG < '1980-01-01';")
end

function event()
    select_skip_columns()
end
