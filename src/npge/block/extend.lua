-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local fix_pos = function(seq, x)
    if seq:circular() then
        local fp = require 'npge.sequence.fixPosition'
        return fp(seq, x)
    elseif x < 0 then
        return 0
    elseif x >= seq:length() then
        return seq:length() - 1
    else
        return x
    end
end

local expandFragment = function(f, left, right)
    local new_start, new_stop
    local new_len = left + f:length() + right
    local circular = f:sequence():circular()
    if new_len > f:sequence():length() and circular then
        -- whole sequence
        new_start = f:start()
        new_stop = f:start() - f:ori()
    else
        new_start = f:start() - left * f:ori()
        new_stop = f:stop() + right * f:ori()
    end
    new_start = fix_pos(f:sequence(), new_start)
    new_stop = fix_pos(f:sequence(), new_stop)
    return new_start, new_stop
end

local getText = function(seq, start, stop, ori)
    local fp = require 'npge.sequence.fixPosition'
    start = fp(seq, start)
    stop = fp(seq, stop)
    local Fragment = require 'npge.model.Fragment'
    return Fragment(seq, start, stop, ori):text()
end

local getRows = function(fragment, new_start, new_stop)
    local left_row, right_row
    if new_start == fragment:start() then
        left_row = ''
    else
        left_row = getText(fragment:sequence(), new_start,
            fragment:start() - fragment:ori(), fragment:ori())
    end
    if new_stop == fragment:stop() then
        right_row = ''
    else
        right_row = getText(fragment:sequence(),
            fragment:stop() + fragment:ori(),
            new_stop, fragment:ori())
    end
    local Fragment = require 'npge.model.Fragment'
    local newf = Fragment(fragment:sequence(), new_start,
        new_stop, fragment:ori())
    if newf == fragment then
        newf = fragment
    end
    return left_row, right_row, newf
end

return function(block, left_length, right_length)
    assert(type(left_length) == 'number')
    right_length = right_length or left_length
    assert(type(right_length) == 'number')
    --
    local left_rows = {}
    local middle_rows = {}
    local right_rows = {}
    local new_fragments = {}
    --
    for f in block:iterFragments() do
        local new_start, new_stop = expandFragment(f,
            left_length, right_length)
        local left_row, right_row, newf = getRows(f,
            new_start, new_stop)
        table.insert(left_rows, left_row)
        table.insert(middle_rows, block:text(f))
        table.insert(right_rows, right_row)
        table.insert(new_fragments, newf)
    end
    --
    local cr = require 'npge.alignment.complement_rows'
    local align_rows = require 'npge.alignment.align_rows'
    local join = require 'npge.alignment.join'
    local only_left = true
    left_rows = cr(left_rows)
    left_rows = align_rows(left_rows, only_left)
    left_rows = cr(left_rows)
    right_rows = align_rows(right_rows, only_left)
    local rows = join(left_rows, middle_rows, right_rows)
    --
    assert(#rows == #new_fragments)
    local for_block = {}
    for i = 1, #new_fragments do
        table.insert(for_block, {new_fragments[i], rows[i]})
    end
    local Block = require 'npge.model.Block'
    local result = Block(for_block)
    if result == block then
        result = block
    end
    return result
end
