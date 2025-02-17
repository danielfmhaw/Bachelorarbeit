local con = sysbench.sql.driver():connect()

function select_without_hash_pruning_range()
    local without_hash_pruning_range_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE KUNDEN_ID BETWEEN 1000 AND 2000;
    ]];
    con:query(without_hash_pruning_range_query)
end

function event()
    select_without_hash_pruning_range()
end