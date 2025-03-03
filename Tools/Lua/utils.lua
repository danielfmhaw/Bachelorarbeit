local utils = {}

function utils.randomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local randIndex = math.random(1, #charset)
        result = result .. charset:sub(randIndex, randIndex)
    end
    return result
end

function lock_file(file)
    local lock_file = file:gsub("%.log$", "") .. ".lock"
    local command = string.format("touch %s", lock_file)
    local result = os.execute(command)
    return result == 0
end

function unlock_file(file)
    local lock_file = file:gsub("%.log$", "") .. ".lock"
    local result = os.remove(lock_file)
    return result == 0
end


local function is_line_in_file(file_name, line)
    local file = io.open(file_name, "r")
    if not file then
        return false
    end

    -- Datei Zeile für Zeile durchsuchen
    for existing_line in file:lines() do
        if existing_line == line then
            file:close()
            return true
        end
    end

    file:close()
    return false
end

function utils.print_results(con, query, custom)
    local log_file = os.getenv("LOG_FILE")
    local query_line = "Executed Query: " .. query:gsub("%s+", " ")

    if lock_file(log_file) and log_file and not is_line_in_file(log_file, query_line) then
        local result = con:query(query)
        io.stderr:write("---------------------- START PRINTING ----------------------\n")
        io.stderr:write(query_line .. "\n")

        if custom then
            io.stderr:write(string.format("CUSTOM_NAME: %s", custom) .. "\n")
        end

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
    unlock_file(log_file)
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