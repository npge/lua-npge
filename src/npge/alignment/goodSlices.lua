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

return function(good_col, min_length, min_end, min_identity)

    assert(min_length >= min_end)

    local block_length = #good_col

    -- count number of good columns at pos <= index
    local good_sum = {}
    good_sum[0] = 0
    for i = 1, block_length do
        good_sum[i] = good_sum[i-1] + (good_col[i] and 1 or 0)
    end

    -- start and stop are 0-based
    local function countGood(start, stop)
        return good_sum[stop + 1] - good_sum[start - 1 + 1]
    end

    local function allGood(start, stop)
        local length = stop - start + 1
        return countGood(start, stop) == length
    end

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
            if not self:valid() then
                return self
            end
            local start1 = self.start
            local stop1 = self:stop()
            while not allGood(start1, start1 + min_end - 1) and
                    start1 + min_end - 1 < stop1 do
                start1 = start1 + 1
            end
            while not allGood(stop1 - min_end + 1, stop1) and
                    start1 + min_end - 1 < stop1 do
                stop1 = stop1 - 1
            end
            -- result
            local length1 = stop1 - start1 + 1
            return Slice(start1, length1)
        end,

        valid = function(self)
            return self.length >= min_length and
                self.start >= 0 and self:stop() < block_length
        end,
    }
    slice_mt.__index = slice_mt

    -- Return if identity (good_count / min_length) is good
    local identity = require 'npge.alignment.identity'
    local less = require 'npge.block.identity'.less
    local min_good = min_length * min_identity
    local function goodIdentity(good_count)
        return not less(good_count, min_good)
    end

    -- Return if slice {start, start + min_length - 1} is good
    local function goodSlice(start)
        local stop = start + min_length - 1
        return goodIdentity(countGood(start, stop))
    end

    -- Return list of joined slices
    local function joinedSlices()
        local slices0 = {}
        local last_slice
        local prev_good
        for i = 0, block_length - min_length do
            local curr_good = goodSlice(i)
            if curr_good then
                if i > 0 and prev_good then
                    -- increase previous slice
                    assert(#slices0 > 0)
                    last_slice.length = last_slice.length + 1
                else
                    -- add new slice
                    last_slice = Slice(i, min_length)
                    table.insert(slices0, last_slice)
                end
            end
            prev_good = curr_good
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

    local slices = joinedSlices()
    local result = {}
    while #slices > 0 do
        local selected = maxSlice(slices)
        if selected.length >= min_length then
            local r = {selected.start, selected:stop()}
            table.insert(result, r)
            slices = excludeSlice(slices, selected)
        end
    end
    return result
end
