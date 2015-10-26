-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- Arguments:
-- 1. list of column statuses (true is good column)
-- 2. frame_length (integer)
-- 3. frame_end (integer)
-- 4. min_identity (from 0.0 to 1.0)
-- 5. min_length (integer)

-- Results:
-- 1. List of good slices
--    Each slice is a table {start, stop}
-- Indices start and stop are 0-based.

-- single line to satisfy luacov
-- https://github.com/keplerproject/luacov/issues/33
return function(good_col, frame_length, frame_end, min_identity, min_length)
    local impl = require 'npge.cpp'.func.goodSlices
    local minIdentical = require 'npge.alignment.minIdentical'
    local ident = minIdentical(min_identity)
    return impl(good_col,
        frame_length, frame_end,
        ident, min_length)
end
