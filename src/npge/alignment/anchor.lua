-- use C version if available
local has_c, canchor = pcall(require, 'npge.alignment.canchor')
if has_c then
    return canchor
end

local maxLength = function(rows)
    local max_length = #rows[1]
    for _, row in ipairs(rows) do
        max_length = math.max(max_length, #row)
    end
    return max_length
end

local tableSize = function(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

local addWords = function(rows, start, length, word2pos)
    local seen = {}
    local best_word
    for i, row in ipairs(rows) do
        local slice = row:sub(start, start + length - 1)
        if #slice == length then
            seen[slice] = (seen[slice] or 0) + 1
            if not word2pos[slice] then
                word2pos[slice] = {}
            end
            if not word2pos[slice][i] then
                word2pos[slice][i] = start
                if tableSize(word2pos[slice]) == #rows then
                    best_word = slice
                end
            end
        end
    end
    local word, count = next(seen)
    if count == #rows then
        -- same word in all rows
        best_word = word
        for i, row in ipairs(rows) do
            word2pos[best_word][i] = start
        end
    end
    return best_word
end

return function(rows)
    -- Input:
    --     ......
    --     .....
    --     .......
    -- Output:
    --  ..     ***   ....
    --  ..  ,  *** , ..
    --  ...    ***   ....
    -- left  middle  right
    if #rows == 0 then
        return nil
    end
    local config = require 'npge.config'
    local ANCHOR = config.alignment.ANCHOR
    local max_length = maxLength(rows)
    local last = max_length - ANCHOR + 1
    last = math.min(config.general.MIN_LENGTH, last)
    local word2pos = {}
    local best, best_pos
    for start = 1, last do
        best = addWords(rows, start, ANCHOR, word2pos)
        if best then
            best_pos = word2pos[best]
            break
        end
    end
    --
    if best then
        local left = {}
        local middle = {}
        local right = {}
        for i, row in ipairs(rows) do
            local start = best_pos[i]
            assert(row:sub(start, start + ANCHOR - 1) == best)
            table.insert(left, row:sub(1, best_pos[i] - 1))
            table.insert(middle, best)
            table.insert(right, row:sub(start + ANCHOR))
        end
        return left, middle, right
    else
        return nil
    end
end
