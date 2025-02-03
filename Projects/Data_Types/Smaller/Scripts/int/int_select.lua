local con = sysbench.sql.driver():connect()
function select_query()
    con:query("SELECT COUNT(*) FROM KUNDEN;")
    con:query("SELECT * FROM KUNDEN ORDER BY NAME;")
end

function event()
    select_query()
end
