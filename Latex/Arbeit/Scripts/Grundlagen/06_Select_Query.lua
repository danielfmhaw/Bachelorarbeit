function select_query()
    local join_query = [[
        SELECT k.STADT, SUM(b.UMSATZ) AS Total_Umsatz
        FROM KUNDEN k
        JOIN BESTELLUNG b ON k.NAME = b.FK_KUNDEN
        GROUP BY k.STADT;
    ]]
    db_query(join_query)
end

function event()
    select_query()
end
