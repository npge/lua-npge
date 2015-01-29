-- use C version if available
local has_c, cto_atgcn_and_gap = pcall(require,
    'npge.alignment.cto_atgcn_and_gap')
if has_c then
    return cto_atgcn_and_gap
end

return function(text)
    assert(type(text) == 'string')
    return text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN%-]', '')
end
