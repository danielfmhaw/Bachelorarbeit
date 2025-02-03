local con = sysbench.sql.driver():connect()
function select_leftmost_prefix()
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Müller';")
end

function event()
    select_leftmost_prefix()
end
