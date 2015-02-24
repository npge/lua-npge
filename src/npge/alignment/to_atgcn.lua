-- use C version if available
local has_c, cpp = pcall(require,
    'npge.cpp')
if has_c then
    return cpp.toAtgcn
end

return function(text)
    assert(type(text) == 'string')
    text = text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN]', '')
    return text
end
