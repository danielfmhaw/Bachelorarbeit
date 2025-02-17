local con = sysbench.sql.driver():connect()

function select_with_primary_key()
    local with_primary_key_query = [[
        SELECT *
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.KUNDEN_ID = b.FK_KUNDEN
        WHERE k.GEBURTSTAG = '1985-01-01';
    ]];
    con:query(with_primary_key_query)
end

function event()
    select_with_primary_key()
end