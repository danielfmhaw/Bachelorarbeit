local con = sysbench.sql.driver():connect()
function select_exact_with_prefix()
    -- order by geb (425789 reads) works is only very litte slower than order by vorname (436414 reads) or no order by (437042 reads) => but not worth including in graphs
    con:query("SELECT * FROM KUNDEN WHERE NAME = 'Müller' AND VORNAME LIKE 'M%' ORDER BY GEBURTSTAG;")
end

function event()
    select_exact_with_prefix()
end
