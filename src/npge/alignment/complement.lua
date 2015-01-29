-- use C version if available
local has_c, ccomplement = pcall(require,
    'npge.alignment.ccomplement')
if has_c then
    return ccomplement
end

return function(text)
    text = text:reverse():gsub('[ATGC]',
        {A='T', T='A', C='G', G='C'})
    return text
end
