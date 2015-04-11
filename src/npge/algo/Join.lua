-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local logicalNeighbour = function(f, ori, blockset)
    if ori * f:ori() == 1 then
        return blockset:next(f)
    else
        return blockset:prev(f)
    end
end

local findNeighbour = function(block, ori, bs)
    -- return neightbour and list of pairs {f, f_n}
    local n_b, ori_product -- n for neightbour
    local pairs_list = {}
    for f in block:iterFragments() do
        local n_f = logicalNeighbour(f, ori, bs)
        if not n_f then
            return
        end
        table.insert(pairs_list, {f, n_f})
        if not n_b then
            n_b = bs:blockByFragment(n_f)
            ori_product = n_f:ori() * f:ori()
        else
            local n_b1 = bs:blockByFragment(n_f)
            local ori_product1 = n_f:ori() * f:ori()
            if n_b1 ~= n_b or ori_product1 ~= ori_product then
                return
            end
        end
    end
    assert(n_b)
    return n_b, pairs_list
end

local joinFragments = function(f1, f2, b1, b2, ori)
    local row1 = b1:text(f1)
    local row2 = b2:text(f2)
    if f2:ori() ~= f1:ori() then
        local reverse = require 'npge.fragment.reverse'
        f2 = reverse(f2)
        local C = require 'npge.alignment.complement'
        row2 = C(row2)
    end
    assert(f1:ori() == f2:ori())
    local new_ori = f1:ori()
    assert(f1:sequence() == f2:sequence())
    local new_seq = f1:sequence()
    local new_start, new_stop
    local middle_start, middle_stop
    local left_row, right_row
    if ori == 1 then
        new_start = f1:start()
        new_stop = f2:stop()
        middle_start = f1:stop() + f1:ori()
        middle_stop = f2:start() - f2:ori()
        left_row, right_row = row1, row2
    else
        new_start = f2:start()
        new_stop = f1:stop()
        middle_start = f2:stop() + f2:ori()
        middle_stop = f1:start() - f1:ori()
        left_row, right_row = row2, row1
    end
    local Fragment = require 'npge.model.Fragment'
    local new_f = Fragment(new_seq, new_start,
        new_stop, new_ori)
    local ml = new_f:length() - f1:length() - f2:length()
    assert(ml >= 0)
    local middle_row = ''
    if ml >= 1 then
        local fix_pos = require 'npge.sequence.fixPosition'
        middle_start = fix_pos(new_seq, middle_start)
        middle_stop = fix_pos(new_seq, middle_stop)
        local middle_f = Fragment(new_seq, middle_start,
            middle_stop, new_ori)
        assert(middle_f:length() == ml)
        middle_row = middle_f:text()
    end
    return new_f, left_row, middle_row, right_row
end

local joinBlocks = function(b1, b2, pairs_list, ori)
    local fragments = {}
    local left_rows = {}
    local middle_rows = {}
    local right_rows = {}
    for _, pair in ipairs(pairs_list) do
        local unpack = require 'npge.util.unpack'
        local f1, f2 = unpack(pair)
        local new_f, left_row, middle_row, right_row =
            joinFragments(f1, f2, b1, b2, ori)
        table.insert(fragments, new_f)
        table.insert(left_rows, left_row)
        table.insert(middle_rows, middle_row)
        table.insert(right_rows, right_row)
    end
    local A = require 'npge.alignment'
    middle_rows = A.alignRows(middle_rows)
    local rows = A.join(left_rows, middle_rows, right_rows)
    assert(#rows == #fragments)
    local for_block = {}
    for i = 1, #rows do
        table.insert(for_block, {fragments[i], rows[i]})
    end
    local Block = require 'npge.model.Block'
    return Block(for_block)
end

local findJoined = function(blockset)
    -- for each block look through left and right neighbours
    -- of each fragment;
    -- add joined block, if all fragments have
    -- corresponding fragment in neighbour
    local joined = {}
    for b in blockset:iterBlocks() do
        for ori = -1, 1, 2 do
            local n_b, pp = findNeighbour(b, ori, blockset)
            if n_b and n_b ~= b then
                local new_b = joinBlocks(b, n_b, pp, ori)
                table.insert(joined, new_b)
            end
        end
    end
    return joined
end

return function(blockset)
    -- return joined blocks, which can overlap
    -- algorithm: group blocks by size, go from highest
    -- to lowest; find corresponding blocks, join
    -- corresponding blocks can include different
    -- number of fragment, but all "common" fragments
    -- must share same orientation and number of those
    -- fragments must be >= 2
    local size2blocks = {}
    local max_size = 0
    for block in blockset:iterBlocks() do
        local size = block:size()
        max_size = math.max(max_size, size)
        if not size2blocks[size] then
            size2blocks[size] = {}
        end
        table.insert(size2blocks[size], block)
    end
    --
    local blocks = {}
    local joined = {}
    for size = max_size, 2, -1 do
        if size2blocks[size] then
            for _, block in ipairs(size2blocks[size]) do
                table.insert(blocks, block)
            end
            local BlockSet = require 'npge.model.BlockSet'
            local bs = BlockSet(blockset:sequences(), blocks)
            local joined1 = findJoined(bs)
            for _, block in ipairs(joined1) do
                table.insert(joined, block)
            end
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), joined)
end
