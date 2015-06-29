-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    -- good column = identical and gapless and N-less
    -- AND(
    -- size >= 2 fragments
    -- length >= MIN_LENGTH
    -- identity >= MIN_IDENTITY on each slice of MIN_LENGTH
    -- both ends are good for >= MIN_END
    -- )
    -- Values of these constants are in config.general
    local goodSubblocks = require 'npge.block.goodSubblocks'
    local subblocks = goodSubblocks(block)
    return #subblocks == 1 and subblocks[1] == block
end
