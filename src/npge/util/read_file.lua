return function(fname)
    local f = io.open(fname, "rb")
    local content = f:read("*a")
    f:close()
    return content
end
