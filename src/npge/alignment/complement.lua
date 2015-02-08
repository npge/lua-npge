-- use C version if available
local has_c, cmodel = pcall(require,
    'npge.cmodel')
if has_c then
    return cmodel.complement
end

return function(text)
    text = text:reverse():gsub('[ATGC]',
        {A='T', T='A', C='G', G='C'})
    return text
end
