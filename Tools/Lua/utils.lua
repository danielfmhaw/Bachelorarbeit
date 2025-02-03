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

return utils