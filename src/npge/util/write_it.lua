return function(fname, it)
    local f = io.open(fname, 'w')
    for text in it do
        f:write(text)
    end
    f:close()
end
