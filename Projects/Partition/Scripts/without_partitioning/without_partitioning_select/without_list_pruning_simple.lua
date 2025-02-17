local con = sysbench.sql.driver():connect()

function select_without_list_pruning_simple()
    local without_list_pruning_simple_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.LAND = 'Germany';
    ]];
    con:query(without_list_pruning_simple_query)
end

function event()
    select_without_list_pruning_simple()
end