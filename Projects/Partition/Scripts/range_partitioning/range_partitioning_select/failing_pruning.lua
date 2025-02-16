local con = sysbench.sql.driver():connect()

function failing_pruning_query()
    local join_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE YEAR(k.GEBURTSTAG) = 1985;
    ]];
    con:query(join_query)
end

function event()
    failing_pruning_query()
end
