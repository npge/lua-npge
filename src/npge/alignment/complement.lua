-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- use C version if available
local has_c, cpp = pcall(require,
    'npge.cpp')
if has_c then
    return cpp.func.complement
end

return function(text)
    text = text:reverse():gsub('[ATGC]',
        {A='T', T='A', C='G', G='C'})
    return text
end
