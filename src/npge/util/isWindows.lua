-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return (_G.jit and _G.jit.os == 'Windows') or
    package.config:sub(1,1) == '\\'
