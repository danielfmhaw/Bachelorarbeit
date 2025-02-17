local con = sysbench.sql.driver():connect()

function select_with_pruning()
    local with_pruning_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.GEBURTSTAG BETWEEN '1985-01-01' AND '1985-12-31';
    ]];
    con:query(with_pruning_query)
end

function event()
    select_with_pruning()
end
