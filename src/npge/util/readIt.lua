return function(it)
    local array = {}
    for part in it do
        table.insert(array, part)
    end
    return table.concat(array)
end
