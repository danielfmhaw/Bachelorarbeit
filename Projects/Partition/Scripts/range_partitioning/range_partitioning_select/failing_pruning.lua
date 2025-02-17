local con = sysbench.sql.driver():connect()

function select_failing_pruning()
    local failing_pruning_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE YEAR(k.GEBURTSTAG) = 1985;
    ]];
    con:query(failing_pruning_query)
end

function event()
    select_failing_pruning()
end
