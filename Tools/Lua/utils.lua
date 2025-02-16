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

function utils.print_results(result)
    if result and result.nrows > 0 then
        for i = 1, result.nrows do
            local row = result:fetch_row()
            local output_string = ""
            for j = 1, #row do
                output_string = output_string .. tostring(row[j]) .. " "
            end
            io.stderr:write(output_string .. "\n")
        end
    end
end

function utils.generate_partition_definition_by_year(start_year, end_year, step)
    local partitions = {}
    local partition_number = 1
    for year = start_year, end_year, step do
        local next_year = year + step
        table.insert(partitions, string.format(
            "PARTITION p%d VALUES LESS THAN (%d)", partition_number, next_year
        ))
        partition_number = partition_number + 1
    end
    table.insert(partitions, "PARTITION pmax VALUES LESS THAN MAXVALUE")
    return "PARTITION BY RANGE (YEAR(GEBURTSTAG)) (\n    " .. table.concat(partitions, ",\n    ") .. "\n);"
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