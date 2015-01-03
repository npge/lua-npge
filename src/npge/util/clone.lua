return {
    array = function(x)
        local clone = {}
        for _, item in ipairs(x) do
            table.insert(clone, item)
        end
        return clone
    end,

    dict = function(x)
        local clone = {}
        for key, value in pairs(x) do
            clone[key] = value
        end
        return clone
    end,
}
