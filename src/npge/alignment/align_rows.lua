local align_rows

local compress = function(rows)
    -- filter out empty rows
    -- returns new rows, decompression_info
    local new_rows = {}
    local decompression_info = {}
    for i, row in ipairs(rows) do
        if #row >= 1 then
            table.insert(new_rows, row)
            table.insert(decompression_info, #new_rows)
        else
            table.insert(decompression_info, -1)
        end
    end
    return new_rows, decompression_info
end

local decompress = function(rows, decompression_info)
    -- returns old rows
    local old_rows = {}
    local length = #rows[1]
    local dummy = string.rep('-', length)
    for _, index in ipairs(decompression_info) do
        if index ~= -1 then
            table.insert(old_rows, rows[index])
        else
            table.insert(old_rows, dummy)
        end
    end
    return old_rows
end

local addGaps = function(rows)
    assert(#rows >= 1)
    local max_length = 0
    for _, row in ipairs(rows) do
        max_length = math.max(max_length, #row)
    end
    local result = {}
    for _, row in ipairs(rows) do
        local gaps = string.rep('-', max_length - #row)
        table.insert(result, row .. gaps)
    end
    return result
end

local addGapsForBetterIdentity = function(rows)
    local alignment = require 'npge.alignment'
    local var1 = addGaps(rows)
    local cr = alignment.complement_rows
    local var2 = cr(addGaps(cr(rows)))
    local identity = alignment.identity
    if identity(var1) >= identity(var2) then
        return var1
    else
        return var2
    end
end

local alignRemaining = function(rows)
    local rows1, decompression_info = compress(rows)
    if #rows1 == #rows or #rows1 == 0 then
        return addGapsForBetterIdentity(rows)
    else
        local rows2 = align_rows(rows1)
        return decompress(rows2, decompression_info)
    end
end

local emptyRows = function(n)
    local rows = {}
    for i = 1, n do
        table.insert(rows, '')
    end
    return rows
end

local strip = function(rows, func, only_left)
    local alignment = require 'npge.alignment'
    local left, middle = func(rows)
    local right
    if not only_left then
        middle = alignment.complement_rows(middle)
        right, middle = func(middle)
        right = alignment.complement_rows(right)
        middle = alignment.complement_rows(middle)
    else
        right = emptyRows(#rows)
    end
    return left, middle, right
end

align_rows = function(rows, only_left)
    -- if only_left then left side is considered main
    -- (alignment grows from left to right)
    -- if not only_left, then both left and right
    -- sides are equal (the default)
    local A = require 'npge.alignment'
    local l1, m1, r1 = strip(rows, A.move_identical, only_left)
    local l2, m2, r2 = strip(m1, A.left, only_left)
    local l3, anchor, r3 = A.anchor(m2)
    if anchor then
        l3 = alignRemaining(l3)
        r3 = align_rows(r3, false)
        return A.join(l1, l2, l3, anchor, r3, r2, r1)
    else
        m2 = alignRemaining(m2)
        return A.join(l1, l2, m2, r2, r1)
    end
end

return align_rows
