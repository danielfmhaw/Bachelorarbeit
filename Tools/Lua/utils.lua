local utils = {}

function utils.randomNumber(length)
    local min = 10^(length - 1)
    local max = 10^length - 1
    return math.random(min, max)
end

function utils.randomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local result = ""
    for i = 1, length do
        local randIndex = math.random(1, #charset)
        result = result .. charset:sub(randIndex, randIndex)
    end
    return result
end

function utils.get_cpu_usage()
   local handle = io.popen("uname")
   local os_type = handle:read("*a"):gsub("\n", "")
   handle:close()
   local cpu_usage
   -- Abhängig vom Betriebssystem
   if os_type == "Darwin" then
       handle = io.popen("top -l 1 | grep 'CPU usage' | awk '{print $3 + $5}'")
       cpu_usage = handle:read("*a")
       handle:close()
   elseif os_type == "Linux" then
       handle = io.popen("top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'")
       cpu_usage = handle:read("*a")
       handle:close()
   else
       return
   end
   io.stderr:write("CPU-Usage:" .. cpu_usage:gsub("\n", "") .. "%\n")
end

function utils.print_results(con, query, custom)
    local result = con:query(query)
    local query_line = "Executed Query: " .. query:gsub("%s+", " ")
    local is_count_query = string.find(query, "COUNT%(%*%)") ~= nil

    if is_count_query then
        local row = (result and result.nrows > 0 and result:fetch_row()) or {"error"}
        local output_string = table.concat(row, ";")
        io.stderr:write(query_line .. ";" .. string.format("CustomName:%s", custom) .. ";CountValue:" .. output_string .. "\n")
    else
        io.stderr:write("---------------------- START PRINTING ----------------------\n")
        io.stderr:write(query_line .. "\n")

        if result and result.nrows > 0 then
            for i = 1, result.nrows do
                local row = result:fetch_row()
                local output_string = ""
                for j = 1, #row do
                    output_string = output_string .. tostring(row[j])
                    if j < #row then
                        output_string = output_string .. ";"
                    end
                end
                io.stderr:write(output_string .. "\n")
            end
        end
        io.stderr:write("----------------------  END PRINTING  ----------------------\n\n")
    end
end

function utils.generate_partition_definition_by_year(start_year, end_year, step, use_range_columns)
    local partitions = {}
    local partition_number = 1
    for year = start_year, end_year, step do
        local next_year = year + step
        local partition_def = use_range_columns
            and string.format("PARTITION p%d VALUES LESS THAN ('%d-01-01')", partition_number, next_year)
            or string.format("PARTITION p%d VALUES LESS THAN (%d)", partition_number, next_year)
        table.insert(partitions, partition_def)
        partition_number = partition_number + 1
    end
    table.insert(partitions, "PARTITION pmax VALUES LESS THAN (MAXVALUE)")

    local partition_type = use_range_columns and "RANGE COLUMNS(GEBURTSTAG)" or "RANGE (YEAR(GEBURTSTAG))"

    return "PARTITION BY " .. partition_type .. " (\n    " .. table.concat(partitions, ",\n    ") .. "\n);"
end

function utils.generate_list_partitions(countries)
    local partition_statements = {}
    for _, country in ipairs(countries) do
        local partition_name = country:lower():gsub(" ", "_")
        table.insert(partition_statements, string.format("PARTITION p_%s VALUES IN ('%s')", partition_name, country))
    end
    table.insert(partition_statements, "PARTITION p_other VALUES IN ('Other')")
    return table.concat(partition_statements, ",\n    ")
end

function utils.get_random_countries(countries, n)
    local selected = {}
    local used_indexes = {}

    while #selected < n do
        local rand_index = math.random(#countries)
        if not used_indexes[rand_index] then
            used_indexes[rand_index] = true
            table.insert(selected, countries[rand_index])
        end
    end
    return selected
end

return utils