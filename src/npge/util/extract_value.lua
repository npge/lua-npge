return function(values, key)
    local value = values:match('"' .. key .. '=(.*)"')
    if not value then
        value = values:match(key .. '=(%w*)')
    end
    return value
end
