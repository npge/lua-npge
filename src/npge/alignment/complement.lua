-- use C version if available
local has_c, cpp = pcall(require,
    'npge.cpp')
if has_c then
    return cpp.complement
end

return function(text)
    text = text:reverse():gsub('[ATGC]',
        {A='T', T='A', C='G', G='C'})
    return text
end
