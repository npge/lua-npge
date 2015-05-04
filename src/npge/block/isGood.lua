-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    -- good column = identical and gapless
    -- AND(
    -- size >= 2 fragments
    -- length >= MIN_LENGTH
    -- identity >= MIN_IDENTITY on each slice of MIN_LENGTH
    -- both ends are good for >= MIN_END
    -- )
    -- Values of these constants are in config.general
    local config = require 'npge.config'
    local min_length = config.general.MIN_LENGTH
    -- check size
    if block:size() < 2 then
        return false, 'size', block:size()
    end
    -- check length
    if block:length() < min_length then
        return false, 'length', block:length()
    end
    -- make rows
    local rows = {}
    for fragment in block:iterFragments() do
        table.insert(rows, block:text(fragment))
    end
    -- check identity of end subblocks
    local min_ident = config.general.MIN_IDENTITY
    local identity = require 'npge.alignment.identity'
    local min_cols = config.general.MIN_END
    local _, ident, all = identity(rows, 0, min_cols - 1)
    if ident ~= all then
        return false, 'beginning identity', ident / all
    end
    local _, ident, all = identity(rows,
        block:length() - min_cols, block:length() - 1)
    if ident ~= all then
        return false, 'ending identity', ident / all
    end
    -- check identity of slices of length MIN_LENGTH
    local min_gc = min_length * min_ident
    local function goodIdentity(good_count)
        return good_count >= min_gc
    end
    local goodColumns = require 'npge.cpp'.func.goodColumns
    local col = goodColumns(rows)
    local good_count = 0
    for i = 1, min_length do
        good_count = good_count + (col[i] and 1 or 0)
    end
    if not goodIdentity(good_count) then
        return false, 'identity of slice',
               good_count / min_length
    end
    for new_pos = min_length + 1, block:length() do
        local old_pos = new_pos - min_length
        good_count = good_count + (col[new_pos] and 1 or 0)
        good_count = good_count - (col[old_pos] and 1 or 0)
        local start = old_pos + 1
        if not goodIdentity(good_count) then
            return false, 'identity of slice',
                   good_count / min_length
        end
    end
    return true
end
