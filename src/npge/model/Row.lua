
local Row = {}
local Row_mt = {}
local row_mt = {}

Row_mt.__index = Row_mt
row_mt.__index = row_mt

Row_mt.__call = function(self, text)
    assert(type(text) == 'string')
    assert(#text > 0)
    local starts = {} -- bp at which group of nongaps starts
    local lengths = {} -- total length of this and prev groups
    local prev
    table.insert(lengths, 0)
    for bp = 0, #text - 1 do
        local char = text:sub(bp + 1, bp + 1)
        if char ~= '-' and (not prev or prev == '-') then
            -- new nongap opened
            table.insert(starts, bp)
            local prev_length = lengths[#lengths]
            table.insert(lengths, prev_length + 1)
        elseif char ~= '-' then
            -- increase length of last group of nongaps
            lengths[#lengths] = lengths[#lengths] + 1
        end
        prev = char
    end
    table.insert(starts, #text)
    local row = {_starts=starts, _lengths=lengths}
    return setmetatable(row, row_mt)
end

row_mt.type = function(self)
    return "Row"
end

row_mt.length = function(self)
    local starts = self._starts
    return starts[#starts]
end

row_mt.fragment_length = function(self)
    local lengths = self._lengths
    return lengths[#lengths]
end

row_mt.text = function(self, fragment)
    if fragment then
        assert(type(fragment) == 'string')
        assert(#fragment == self:fragment_length())
    else
        fragment = string.rep('N', self:fragment_length())
    end
    local result = {}
    for bp = 0, self:length() - 1 do
        local fp = self:block2fragment(bp)
        local char
        if fp ~= -1 then
            char = fragment:sub(fp + 1, fp + 1)
        else
            char = '-'
        end
        table.insert(result, char)
    end
    return table.concat(result)
end

row_mt.block2fragment = function(self, blockpos)
    assert(blockpos >= 0)
    assert(blockpos < self:length())
    local starts = self._starts
    local lengths = self._lengths
    local upper = require('npge.util.binary_search').upper
    local index = upper(starts, blockpos) - 1
    if index == 0 then
        -- we are in a gap before first letter
        return -1
    end
    local group_length = lengths[index + 1] - lengths[index]
    local distance = blockpos - starts[index]
    if distance < group_length then
        return lengths[index] + distance
    else
        return -1
    end
end

row_mt.block2left = function(self, blockpos)
    for blockpos1 = blockpos, 0, -1 do
        local fragmentpos = self:block2fragment(blockpos1)
        if fragmentpos ~= -1 then
            return fragmentpos
        end
    end
    return -1
end

row_mt.block2right = function(self, blockpos)
    for blockpos1 = blockpos, self:length() - 1 do
        local fragmentpos = self:block2fragment(blockpos1)
        if fragmentpos ~= -1 then
            return fragmentpos
        end
    end
    return -1
end

row_mt.block2nearest = function(self, blockpos)
    for distance = 0, self:length() - 1 do
        local left = blockpos - distance
        if left >= 0 then
            local fragmentpos = self:block2fragment(left)
            if fragmentpos ~= -1 then
                return fragmentpos
            end
        end
        local right = blockpos + distance
        if right < self:length() then
            local fragmentpos = self:block2fragment(right)
            if fragmentpos ~= -1 then
                return fragmentpos
            end
        end
    end
end

row_mt.fragment2block = function(self, fragmentpos)
    assert(fragmentpos >= 0)
    assert(fragmentpos < self:fragment_length())
    local starts = self._starts
    local lengths = self._lengths
    local upper = require('npge.util.binary_search').upper
    local index = upper(lengths, fragmentpos) - 1
    local distance = fragmentpos - lengths[index]
    return starts[index] + distance
end

return setmetatable(Row, Row_mt)

