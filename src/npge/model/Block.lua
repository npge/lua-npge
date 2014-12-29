
local Block = {}
local Block_mt = {}
local block_mt = {}

Block_mt.__index = Block_mt
block_mt.__index = block_mt

Block_mt.to_atgcn_and_gap = function(text)
    assert(type(text) == 'string')
    return text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN%-]', '')
end

Block_mt.__call = function(self, fragments)
    local math = require 'math'
    assert(#fragments > 0)
    local get0 = function(x)
        if x.type and x:type() == 'Fragment' then
            return x
        else
            assert(#x == 2)
            local fragment = x[1]
            local row = Block.to_atgcn_and_gap(x[2])
            local Sequence = require 'npge.model.Sequence'
            assert(fragment:text() == Sequence.to_atgcn(row))
            return fragment, row
        end
    end
    -- memoization
    local get_cache = {}
    local get = function(x)
        if get_cache[x] then
            local unpack = require 'npge.util.unpack'
            local f, row = unpack(get_cache[x])
            return f, row
        else
            local f, row = get0(x)
            get_cache[x] = {f, row}
            return f, row
        end
    end
    local first_f, first_row = get(fragments[1])
    local length = first_row and #first_row or 0
    local ff = {}
    for _, x in ipairs(fragments) do
        local f, row = get(x)
        if (first_row and not row)
                or (not first_row and row) then
            error("Pass rows for all or for none")
        end
        if first_row then
            assert(#first_row == #row)
        else
            length = math.max(length, f:size())
        end
    end
    assert(length)
    assert(length > 0)
    for _, x in ipairs(fragments) do
        local f, row = get(x)
        if not row then
            local gaps = length - f:size()
            row = f:text() .. ("-"):rep(gaps)
        end
        ff[f] = row
    end
    local block = {_fragments=ff, _length=length,
        _size=#fragments}
    return setmetatable(block, block_mt)
end

block_mt.length = function(self)
    return self._length
end

block_mt.size = function(self)
    return self._size
end

block_mt.fragments = function(self)
    local ff = {}
    for f, row in pairs(self._fragments) do
        table.insert(ff, f)
    end
    return ff
end

block_mt.iter_fragments = function(self)
    local f
    return function()
        f = next(self._fragments, f)
        return f
    end
end

return setmetatable(Block, Block_mt)
