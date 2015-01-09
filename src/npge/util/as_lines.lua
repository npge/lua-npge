return function(text)
    local result = {}
    local step = 50
    for i = 1, #text, step do
        table.insert(result, text:sub(i, i + step - 1))
    end
    return table.concat(result, "\n")
end
