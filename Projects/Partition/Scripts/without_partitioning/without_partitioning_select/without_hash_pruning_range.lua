local con = sysbench.sql.driver():connect()

function kunden_id_range()
    local kunden_id_range_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE KUNDEN_ID BETWEEN 1000 AND 2000;
    ]];
    con:query(kunden_id_range_query)
end

function event()
    kunden_id_range()
end