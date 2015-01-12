local has_gap_of_min_length = function(block, min_length)
    for fragment in block:iter_fragments() do
        local row = block:text(fragment)
        local gap_length = 0
        for i = 1, block:length() do
            if row:sub(i, i) == '-' then
                gap_length = gap_length + 1
                if gap_length >= min_length then
                    return true
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
        return false
    end
    -- check length
    if block:length() < min_length then
        return false
    end
    -- check identity
    local min_ident = config.general.MIN_IDENTITY
    local identity = require 'npge.block.identity'
    if identity.less(identity(block), min_ident) then
        return false
    end
    -- check identity of end subblocks
    local slice = require 'npge.block.slice'
    local min_cols = config.general.MIN_END_IDENTICAL_COLUMNS
    local beginning = slice(block, 0, min_cols - 1)
    if identity.less(identity(beginning), 1.0) then
        return false
    end
    local ending = slice(block, block:length() - min_cols,
        block:length() - 1)
    if identity.less(identity(ending), 1.0) then
        return false
    end
    -- check gap length
    if has_gap_of_min_length(block, min_length) then
        return false
    end
    return true
end
