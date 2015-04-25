-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- Arguments:
-- 1. list of column statuses (true is good column)
-- 2. min_length (integer)
-- 3. min_identity (from 0.0 to 1.0)

-- Results:
-- 1. List of good slices
--    Each slice is a table { start = ... , stop() = ... }
-- Indices start and stop start from 0

return function(good_col, min_length, min_identity)

    local block_length = #good_col

    -- class Slice

    local slice_mt

    local function Slice(start, length)
        local self = {}
        self.start = start
        self.length = length
        return setmetatable(self, slice_mt)
    end

    slice_mt = {
        stop = function(self)
            return self.start + self.length - 1
        end,

        -- compare by length
        __lt = function(self, other)
            return self.length < other.length or
                (self.length == other.length and
                self.start < other.start)
        end,

        overlaps = function(self, other)
            if other.start <= self.start and
                    self.start <= other:stop() then
                return true
            end
            if other.start <= self:stop() and
                    self:stop() <= other:stop() then
                return true
            end
            return false
        end,

        exclude = function(self, other)
            local start1 = self.start
            local stop1 = self:stop()
            if other.start <= self.start and
                    self.start <= other:stop() then
                start1 = other:stop() + 1
            end
            if other.start <= self:stop() and
                    self:stop() <= other:stop() then
                stop1 = other.start - 1
            end
            local length1 = stop1 - start1 + 1
            return Slice(start1, length1)
        end,

        strip = function(self)
            local start1 = self.start
            local stop1 = self:stop()
            while not good_col[start1 + 1] and
                    start1 < stop1 do
                start1 = start1 + 1
            end
            while not good_col[stop1 + 1] and
                    start1 < stop1 do
                stop1 = stop1 - 1
            end
            local length1 = stop1 - start1 + 1
            return Slice(start1, length1)
        end,

        valid = function(self)
            return self.length >= min_length and
                self.start >= 0 and self:stop() < block_length
        end,
    }
    slice_mt.__index = slice_mt

    -- convert values in good_col to 0 or 1
    local good_col1 = {}
    for i = 1, #good_col do
        good_col1[i] = good_col[i] and 1 or 0
    end

    -- Return if identity (good_count / min_length) is good
    local identity = require 'npge.alignment.identity'
    local less = require 'npge.block.identity'.less
    local min_good = min_length * min_identity
    local function goodIdentity(good_count)
        return not less(good_count, min_good)
    end

    -- Return list of statuses of slices of length min_length
    local function findGoodSlices()
        local good_slice = {}
        local good_count = 0
        for i = 1, min_length do
            good_count = good_count + good_col1[i]
        end
        good_slice[1] = goodIdentity(good_count)
        for new_pos = min_length + 1, block_length do
            local old_pos = new_pos - min_length
            good_count = good_count + good_col1[new_pos]
            good_count = good_count - good_col1[old_pos]
            local start = old_pos + 1
            good_slice[start] = goodIdentity(good_count)
        end
        return good_slice
    end

    -- Return list of joined slices
    local function joinSlices(good_slice)
        local slices0 = {}
        local last_slice
        for i = 1, block_length - min_length + 1 do
            if good_slice[i] then
                if i > 1 and good_slice[i - 1] then
                    -- increase previous slice
                    assert(#slices0 > 0)
                    last_slice.length = last_slice.length + 1
                else
                    -- add new slice
                    last_slice = Slice(i - 1, min_length)
                    table.insert(slices0, last_slice)
                end
            end
        end
        local slices = {}
        for _, slice in ipairs(slices0) do
            slice = slice:strip()
            if slice:valid() then
                table.insert(slices, slice)
            end
        end
        return slices
    end

    local function maxSlice(slices)
        local result = slices[1]
        for _, slice in ipairs(slices) do
            if slice > result then
                result = slice
            end
        end
        return result
    end

    -- Exclude selected slice from slices, return new slices
    local function excludeSlice(slices, selected)
        local slices1 = {}
        for _, slice in ipairs(slices) do
            if not slice:overlaps(selected) then
                table.insert(slices1, slice)
            else
                slice = slice:exclude(selected):strip()
                if slice:valid() then
                    table.insert(slices1, slice)
                end
            end
        end
        return slices1
    end

    local good_slice = findGoodSlices()
    local slices = joinSlices(good_slice)
    local result = {}
    while #slices > 0 do
        local selected = maxSlice(slices)
        if selected.length >= min_length then
            table.insert(result, selected)
            slices = excludeSlice(slices, selected)
        end
    end
    return result
end
