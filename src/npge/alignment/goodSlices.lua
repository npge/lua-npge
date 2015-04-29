-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- Arguments:
-- 1. list of column statuses (true is good column)
-- 2. min_length (integer)
-- 3. min_end (integer) -- number of begin and end good columns
-- 4. min_identity (from 0.0 to 1.0)

-- Results:
-- 1. List of good slices
--    Each slice is a table {start, stop}
-- Indices start and stop start from 0

return require 'npge.cpp'.func.goodSlices
