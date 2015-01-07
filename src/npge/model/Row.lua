-- use C version if available
local has_crow, crow = pcall(require, 'npge.model.cRow')
if has_crow then
    return crow
end

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

row_mt.__eq = function(self, other)
    local arrays_equal = require 'npge.util.arrays_equal'
    return arrays_equal(self._starts, other._starts) and
        arrays_equal(self._lengths, other._lengths)
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
    local starts = self._starts
    local lengths = self._lengths
    local result = {}
    local result_length = 0
    for index, bp in ipairs(starts) do
        -- gaps before this nongap group
        local gaps_before = bp - result_length
        local gap = string.rep('-', gaps_before)
        table.insert(result, gap)
        if index < #starts then
            local start = lengths[index]
            local stop = lengths[index + 1] - 1
            local group = fragment:sub(start + 1, stop + 1)
            table.insert(result, group)
            result_length = bp + #group
        end
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
        -- last member of the group
        return lengths[index + 1] - 1
    end
end

row_mt.block2right = function(self, blockpos)
    assert(blockpos >= 0)
    assert(blockpos < self:length())
    local starts = self._starts
    local lengths = self._lengths
    local upper = require('npge.util.binary_search').upper
    local index = upper(starts, blockpos) - 1
    if index == 0 then
        -- we are in a gap before first letter
        return 0
    end
    local group_length = lengths[index + 1] - lengths[index]
    local distance = blockpos - starts[index]
    if distance < group_length then
        return lengths[index] + distance
    elseif index + 1 == #lengths then
        -- after last group
        return -1
    else
        -- last member of the group
        return lengths[index + 1]
    end
end

row_mt.block2nearest = function(self, blockpos)
    assert(blockpos >= 0)
    assert(blockpos < self:length())
    local starts = self._starts
    local lengths = self._lengths
    local upper = require('npge.util.binary_search').upper
    local index = upper(starts, blockpos) - 1
    if index == 0 then
        -- we are in a gap before first letter
        return 0
    end
    local group_length = lengths[index + 1] - lengths[index]
    local distance = blockpos - starts[index]
    if distance < group_length then
        return lengths[index] + distance
    elseif index + 1 == #lengths then
        -- after last group
        return lengths[#lengths] - 1
    else
        local left_distance = distance - group_length + 1
        local right_distance = starts[index + 1] - blockpos
        if left_distance <= right_distance then
            return lengths[index + 1] - 1
        else
            return lengths[index + 1]
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

