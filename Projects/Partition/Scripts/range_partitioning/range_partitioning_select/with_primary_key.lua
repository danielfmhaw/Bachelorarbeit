local con = sysbench.sql.driver():connect()

function normal_query()
    local join_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.GEBURTSTAG = '1985-01-01';
    ]];
    con:query(join_query)
end

function event()
    normal_query()
end