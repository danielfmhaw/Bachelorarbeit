local con = sysbench.sql.driver():connect()
function cleanup()
    con:query("DROP TABLE IF EXISTS BESTELLUNG;")
    con:query("DROP TABLE IF EXISTS KUNDEN;")
    print("Cleanup successfully done")
end