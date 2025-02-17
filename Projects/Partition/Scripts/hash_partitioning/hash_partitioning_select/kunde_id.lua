local con = sysbench.sql.driver():connect()

function select_kunde_id()
    local kunde_id_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE KUNDEN_ID = 1000;
    ]];
    con:query(kunde_id_query)
end

function event()
    select_kunde_id()
end