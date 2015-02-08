-- use C version if available
local has_c, cmodel = pcall(require,
    'npge.cmodel')
if has_c then
    return cmodel.toAtgcn
end

return function(text)
    assert(type(text) == 'string')
    text = text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN]', '')
    return text
end
