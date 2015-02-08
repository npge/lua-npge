-- use C version if available
local has_c, cmodel = pcall(require,
    'npge.cmodel')
if has_c then
    return cmodel.toAtgcnAndGap
end

return function(text)
    assert(type(text) == 'string')
    return text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN%-]', '')
end
