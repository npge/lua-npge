return function(str)
    local text = str:gsub("%s+$", "")
    text = text:gsub("^%s+", "")
    return text
end
