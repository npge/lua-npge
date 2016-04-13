-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(cmd, mode)
    -- http://lua.2524044.n2.nabble.com/io-popen-s-rb-td5594024.html
    -- Windows requires 'b', other systems may forbid it
    local isWindows = require 'npge.util.isWindows'
    local suffix = isWindows and 'b' or ''
    return io.popen(cmd, mode .. suffix)
end
