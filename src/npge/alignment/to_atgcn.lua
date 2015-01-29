-- use C version if available
local has_c, cto_atgcn = pcall(require,
    'npge.alignment.cto_atgcn')
if has_c then
    return cto_atgcn
end

return function(text)
    assert(type(text) == 'string')
    text = text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN]', '')
    return text
end
