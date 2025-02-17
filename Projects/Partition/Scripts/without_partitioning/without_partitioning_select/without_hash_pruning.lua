local con = sysbench.sql.driver():connect()

function select_without_hash_pruning()
    local without_hash_pruning_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE KUNDEN_ID = 1000;
    ]];
    con:query(without_hash_pruning_query)
end

function event()
    select_without_hash_pruning()
end