if sysbench.cmdline.command == nil then
    error("Command is required. Supported commands: run")
end

sysbench.cmdline.options = {
    point_selects = {"Number of point SELECT queries to run", 5},
    skip_trx = {"Do not use BEGIN/COMMIT; Use global auto_commit value", false}
}

-- Called by SysBench one time to initialize this script
function thread_init()
    -- Initialize the SysBench MySQL driver
    drv = sysbench.sql.driver()

    -- Create a connection to MySQL
    con = drv:connect()
end

-- Called by SysBench when the script is done executing
function thread_done()
    -- Disconnect/close the connection to MySQL
    con:disconnect()
end

-- Called by SysBench for each execution
function event()
    -- Begin transaction if transactions are enabled
    if not sysbench.opt.skip_trx then
        con:query("BEGIN")
    end

    -- Execute SELECT and INSERT statements
    execute_selects()
    execute_inserts()

    -- Commit transaction if transactions are enabled
    if not sysbench.opt.skip_trx then
        con:query("COMMIT")
    end
end

-- SELECT queries (adapted for the KUNDEN table)
local select_queries = {
    "SELECT COUNT(*) FROM KUNDEN",
    "SELECT * FROM KUNDEN WHERE KUNDEN_ID = %d",
    "SELECT * FROM KUNDEN WHERE NAME LIKE '%s%%'",
    "SELECT * FROM KUNDEN ORDER BY KUNDEN_ID DESC LIMIT 10"
}

-- INSERT statement (for KUNDEN table)
local insert_query = "INSERT INTO KUNDEN (NAME, KONTAKT, STADT) VALUES ('%s', '%s', '%s')"

function execute_selects()
    -- Execute the COUNT(*) query to get the total number of rows in the KUNDEN table
    con:query(select_queries[1])

    -- Loop to run point SELECT queries
    for i = 1, sysbench.opt.point_selects do
        -- Randomly pick a query from the SELECT queries array
        local rand_query = select_queries[math.random(2, #select_queries)]

        -- If it's an ID-based query, generate a random KUNDEN_ID
        if rand_query:find("WHERE KUNDEN_ID") then
            local id = sysbench.rand.pareto(1, 1000) -- Assume up to 1000 customers
            con:query(string.format(rand_query, id))
        else
            -- Generate a random name prefix for LIKE queries
            local random_name = sysbench.rand.string(string.rep("@", sysbench.rand.special(2, 8)))
            con:query(string.format(rand_query, random_name))
        end
    end
end

-- Generate random JSON contact data
function create_random_contact()
    local number = sysbench.rand.string(string.rep("1", sysbench.rand.uniform(7, 10)))
    return string.format('{"nummer": "%s"}', number)
end

-- Generate a random city
local cities = { "Hamburg", "Berlin", "Munich", "Cologne", "Frankfurt" }

function execute_inserts()
    -- Generate fake data for the INSERT operation
    local name = sysbench.rand.string("Name-" .. string.rep("@", sysbench.rand.special(2, 8)))
    local kontakt = create_random_contact()
    local city = cities[math.random(#cities)]

    -- Execute the INSERT into the KUNDEN table
    con:query(string.format(insert_query, name, kontakt, city))
end