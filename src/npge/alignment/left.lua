return function(rows, right_aligned)
    -- Input:
    --     ......
    --     .....
    --     .......
    -- Output:
    --     .-.   ....
    --     ... , ..
    --     ...   ....
    -- If right_aligned, then right end is considered aligned
    -- properly (many identical columns after right end).
    -- This function allows point mutations: mismatches and
    -- gaps. Module config.alignment specifies how many
    -- identical columns must be around a point mutation.
    local config = require 'npge.config'
    local MISMATCH_CHECK = config.alignment.MISMATCH_CHECK
    local GAP_CHECK = config.alignment.GAP_CHECK

    local posShifted = function(shift, pos)
        local result = {}
        for _, x in ipairs(pos) do
            table.insert(result, x + shift)
        end
        return result
    end

    local allExist = function(pos)
        for i, x in ipairs(pos) do
            if x < 1 or x > #rows[i] then
                return false
            end
        end
        return true
    end

    local anyExists = function(pos)
        for i, x in ipairs(pos) do
            if x >= 1 and x <= #rows[i] then
                return true
            end
        end
        return false
    end

    local isIdentical = function(pos)
        local first
        for i, x in ipairs(pos) do
            local c = rows[i]:sub(x, x)
            assert(#c == 1)
            if first and first ~= c then
                return false
            elseif not first then
                first = c
            end
        end
        return true
    end

    local identicalLeft = function(n_columns, pos)
        for i = 1, n_columns do
            local pos1 = posShifted(-i, pos)
            if allExist(pos1) then
                if not isIdentical(pos1) then
                    return false
                end
            elseif anyExists(pos1) then
                return false
            end
            -- if all rows do not exist at the position,
            -- then it is considered identical,
            -- because it is to left of the alignment
        end
        return true
    end

    local identicalRight = function(n_columns, pos)
        for i = 1, n_columns do
            local pos1 = posShifted(i, pos)
            if allExist(pos1) then
                if not isIdentical(pos1) then
                    return false
                end
            elseif anyExists(pos1) then
                return false
            elseif not right_aligned then
                return false
            end
        end
        return true
    end

    local identicalAround = function(n_columns, pos)
        return identicalLeft(n_columns, pos) and
            identicalRight(n_columns, pos)
    end

    local allLetters = function(pos)
        local variants_set = {}
        for i, row in ipairs(rows) do
            local c = row:sub(pos[i], pos[i])
            if #c == 1 then
                variants_set[c] = true
            end
        end
        local variants = {}
        for c, _ in pairs(variants_set) do
            table.insert(variants, c)
        end
        return variants
    end

    local posForGapVariant = function(variant, pos)
        -- "gap variant" is letter paired with gap
        -- can return non-existing pos
        local pos1 = {}
        for i, row in ipairs(rows) do
            local c = row:sub(pos[i], pos[i])
            local new_x
            if c == variant then
                new_x = pos[i] + 1
            else
                new_x = pos[i]
            end
            table.insert(pos1, new_x)
        end
        return pos1
    end

    local checkGapVariants = function(variants, pos)
        local accepted = {}
        for _, variant in ipairs(variants) do
            local pos1 = posForGapVariant(variant, pos)
            local pos2 = posShifted(-1, pos1)
            if identicalRight(GAP_CHECK, pos2) then
                accepted[variant] = pos1
            end
        end
        return accepted
    end

    local selectBestVariant = function(accepted)
        for check = GAP_CHECK, GAP_CHECK * 10 do
            local one_variant = assert(next(accepted))
            local new_accepted = {}
            local count = 0
            for variant, pos in pairs(accepted) do
                if identicalRight(check, pos) then
                    new_accepted[variant] = pos
                    count = count + 1
                end
            end
            if count == 1 then
                local variant, pos = next(new_accepted)
                return variant, pos
            elseif count == 0 then
                return one_variant, accepted[one_variant]
            else
                accepted = new_accepted
            end
        end
    end

    local findBestGap = function(pos)
        local all_variants = allLetters(pos)
        local accepted = checkGapVariants(all_variants, pos)
        if next(accepted) then
            local variant, pos1 = selectBestVariant(accepted)
            return pos1
        end
    end

    ---

    local aligned = {}
    local pos0 = {} -- array of 1-based indexes inside row
    for _, row in ipairs(rows) do
        -- list of char's
        table.insert(aligned, {})
        table.insert(pos0, 1)
        assert(#row >= 1)
    end

    local moveToPos = function(pos1)
        -- one column
        for i, row in ipairs(rows) do
            local c
            if pos0[i] == pos1[i] then
                c = '-'
            else
                c = row:sub(pos0[i], pos1[i] - 1)
            end
            assert(#c == 1)
            table.insert(aligned[i], c)
        end
        pos0 = pos1
    end

    local moveWholeRow = function()
        moveToPos(posShifted(1, pos0))
    end

    local identical_group = 0
    while anyExists(pos0) do
        if allExist(pos0) and isIdentical(pos0) then
            moveWholeRow()
            identical_group = identical_group + 1
        else
            identical_group = 0
            local ok = false
            if allExist(pos0) and
                    identicalAround(MISMATCH_CHECK, pos0) then
                moveWholeRow()
                ok = true
            elseif identicalLeft(GAP_CHECK, pos0) then
                local gap_pos = findBestGap(pos0)
                if gap_pos then
                    moveToPos(gap_pos)
                    ok = true
                end
            end
            if not ok then
                break
            end
        end
    end

    local result = {}
    local tails = {}
    for i, row in ipairs(aligned) do
        table.insert(result, table.concat(row))
        table.insert(tails, rows[i]:sub(pos0[i]))
    end
    return result, tails
end
