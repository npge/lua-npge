-- use C version if available
local has_c, cpp =
    pcall(require, 'npge.cpp')
if has_c then
    return cpp.Block
end

local Block = {}
local Block_mt = {}
local block_mt = {}

Block_mt.__index = Block_mt
block_mt.__index = block_mt

Block_mt.__call = function(self, fragments)
    assert(#fragments > 0, 'Empty block')
    local get0 = function(x)
        if x.type and x:type() == 'Fragment' then
            return x
        else
            assert(#x == 2, "Provide pairs {fragment, row}")
            local fragment = x[1]
            local to_atgcn_and_gap =
                require 'npge.alignment.to_atgcn_and_gap'
            local row = to_atgcn_and_gap(x[2])
            local to_atgcn = require 'npge.alignment.to_atgcn'
            assert(fragment:text() == to_atgcn(row),
                "Row's text doesn't match Fragment's text")
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
            length = math.max(length, f:length())
        end
    end
    assert(length)
    assert(length > 0)
    for _, x in ipairs(fragments) do
        local f, row = get(x)
        if not row then
            local gaps = length - f:length()
            row = f:text() .. ("-"):rep(gaps)
        end
        ff[f] = row
    end
    local block = {_fragments=ff, _length=length,
        _size=#fragments}
    return setmetatable(block, block_mt)
end

block_mt.__eq = function(self, other)
    if self:size() ~= other:size() then
        return false
    end
    local id2row = {}
    for fragment, row in pairs(self._fragments) do
        id2row[fragment:id()] = row
    end
    for fragment1, row1 in pairs(other._fragments) do
        local row = id2row[fragment1:id()]
        if not row or row ~= row1 then
            return false
        end
    end
    return true
end

block_mt.__tostring = function(self)
    local text = 'Block of %d fragments, length %d'
    return text:format(self:size(), self:length())
end

block_mt.type = function(self)
    return "Block"
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

block_mt.text = function(self, fragment)
    local text = assert(self._fragments[fragment])
    return text
end

block_mt.block2fragment = function(self, fragment, blockpos)
    assert(0 <= blockpos)
    assert(blockpos < self:length())
    local row = self._fragments[fragment]
    assert(row)
    if row:sub(blockpos + 1, blockpos + 1) == '-' then
        return -1
    end
    local part = row:sub(1, blockpos + 1)
    local to_atgcn = require 'npge.alignment.to_atgcn'
    local bases = #(to_atgcn(part))
    return bases - 1
end

block_mt.block2left = function(self, fragment, blockpos)
    assert(0 <= blockpos)
    assert(blockpos < self:length())
    local row = self._fragments[fragment]
    assert(row)
    local part = row:sub(1, blockpos + 1)
    local to_atgcn = require 'npge.alignment.to_atgcn'
    local bases = #(to_atgcn(part))
    return bases - 1
    -- -1 if before first
end

block_mt.block2right = function(self, fragment, blockpos)
    assert(0 <= blockpos)
    assert(blockpos < self:length())
    local row = self._fragments[fragment]
    assert(row)
    local part = row:sub(1, blockpos + 1)
    local to_atgcn = require 'npge.alignment.to_atgcn'
    local bases = #(to_atgcn(part))
    if row:sub(blockpos + 1, blockpos + 1) ~= '-' then
        return bases - 1
    end
    if bases == fragment:length() then
        -- after all bases
        return -1
    end
    return bases
end

return setmetatable(Block, Block_mt)
