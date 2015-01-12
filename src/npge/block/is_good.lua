local find_gap = function(block, min_length)
    for fragment in block:iter_fragments() do
        local row = block:text(fragment)
        local gap_length = 0
        for i = 1, block:length() do
            if row:sub(i, i) == '-' then
                gap_length = gap_length + 1
                if gap_length >= min_length then
                    return true, gap_length
                end
            else
                gap_length = 0
            end
        end
    end
    return false
end

return function(block)
    -- AND(
    -- size >= 2 fragments
    -- length >= config.general.MIN_LENGTH
    -- identity >= config.general.MIN_IDENTITY
    -- no gaps longer or equal to config.general.MIN_LENGTH
    -- both ends are identical and gapsless for at least
    --     config.general.MIN_END_IDENTICAL_COLUMNS
    -- )
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
    -- check identity
    local min_ident = config.general.MIN_IDENTITY
    local identity = require 'npge.block.identity'
    local ident = identity(block)
    if identity.less(ident, min_ident) then
        return false, 'identity', ident
    end
    -- check identity of end subblocks
    local slice = require 'npge.block.slice'
    local min_cols = config.general.MIN_END_IDENTICAL_COLUMNS
    local beginning = slice(block, 0, min_cols - 1)
    local ident = identity(beginning)
    if identity.less(ident, 1.0) then
        return false, 'beginning identity', ident
    end
    local ending = slice(block, block:length() - min_cols,
        block:length() - 1)
    local ident = identity(ending)
    if identity.less(identity(ending), 1.0) then
        return false, 'ending identity', ident
    end
    -- check gap length
    local has_long_gap, long_gap = find_gap(block, min_length)
    if has_long_gap then
        return false, 'long gaps', long_gap
    end
    return true
end
