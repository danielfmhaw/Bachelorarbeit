local con = sysbench.sql.driver():connect()

function with_pruning()
    local join_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.GEBURTSTAG BETWEEN '1985-01-01' AND '1985-12-31';
    ]];
    con:query(join_query)
end

function event()
    with_pruning()
end
