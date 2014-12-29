local model = require 'npge.model'
local Row = model.Row

describe("model.row", function()
    it("throws on empty string", function()
        assert.has_error(function()
            Row("")
        end)
    end)

    it("uses row A-T-G-C", function()
        local r = Row("A-T-G-C")
        assert.are.equal(r:length(), 7)
        assert.are.equal(r:fragment_length(), 4)
        assert.are.equal(r:text(), 'N-N-N-N')
        -- block2fragment
        assert.are.equal(r:block2fragment(0), 0)
        assert.are.equal(r:block2fragment(1), -1)
        assert.are.equal(r:block2fragment(2), 1)
        assert.are.equal(r:block2fragment(3), -1)
        assert.are.equal(r:block2fragment(4), 2)
        assert.are.equal(r:block2fragment(5), -1)
        assert.are.equal(r:block2fragment(6), 3)
        assert.has_error(function()
            r:block2fragment(-1)
        end)
        assert.has_error(function()
            r:block2fragment(-100)
        end)
        assert.has_error(function()
            r:block2fragment(7)
        end)
        assert.has_error(function()
            r:block2fragment(100)
        end)
        -- fragment2block
        assert.are.equal(r:fragment2block(0), 0)
        assert.are.equal(r:fragment2block(1), 2)
        assert.are.equal(r:fragment2block(2), 4)
        assert.are.equal(r:fragment2block(3), 6)
        assert.has_error(function()
            r:fragment2block(-1)
        end)
        assert.has_error(function()
            r:fragment2block(-100)
        end)
        assert.has_error(function()
            r:fragment2block(4)
        end)
        assert.has_error(function()
            r:fragment2block(100)
        end)
    end)

    local check_row = function(text)
        local Block = require 'npge.model.Block'
        text = Block.to_atgcn_and_gap(text)
        return function()
            local r = Row(text)
            assert.are.equal(r:length(), #text)
            local Sequence = require 'npge.model.Sequence'
            local ungapped = Sequence.to_atgcn(text)
            assert.are.equal(r:fragment_length(), #ungapped)
            local text1 = text:gsub('[^-]', 'N')
            assert.are.equal(r:text(), text1)
            assert.are.equal(r:text(ungapped), text)
            local fp = 0
            for bp = 0, #text - 1 do
                local char = text:sub(bp + 1, bp + 1)
                if char ~= '-' then
                    assert.are.equal(r:block2fragment(bp), fp)
                    assert.are.equal(r:fragment2block(fp), bp)
                    assert.are.equal(r:block2left(bp), fp)
                    assert.are.equal(r:block2right(bp), fp)
                    assert.are.equal(r:block2nearest(bp), fp)
                    fp = fp + 1
                else
                    assert.are.equal(r:block2fragment(bp), -1)
                    local left = r:block2left(bp)
                    local right = r:block2right(bp)
                    local nearest = r:block2nearest(bp)
                    if fp >= 1 then
                        assert.are.equal(left, fp - 1)
                    else
                        assert.are.equal(left, -1)
                    end
                    if fp < #ungapped then
                        assert.are.equal(right, fp)
                    else
                        assert.are.equal(right, -1)
                    end
                    local nearest = r:block2nearest(bp)
                    if left ~= -1 and right ~= -1 then
                        assert(nearest == left or
                               nearest == right)
                    elseif left ~= -1 then
                        assert.equal(nearest, left)
                    elseif right ~= -1 then
                        assert.equal(nearest, right)
                    else
                        assert.equal(nearest, -1)
                    end
                end
            end
            assert.has_error(function()
                r:block2fragment(-1)
            end)
            assert.has_error(function()
                r:block2fragment(-100)
            end)
            assert.has_error(function()
                r:block2fragment(#text)
            end)
            assert.has_error(function()
                r:block2fragment(2 * #text)
            end)
            assert.has_error(function()
                r:fragment2block(-1)
            end)
            assert.has_error(function()
                r:fragment2block(-100)
            end)
            assert.has_error(function()
                r:fragment2block(#ungapped)
            end)
            assert.has_error(function()
                r:fragment2block(#ungapped * 2)
            end)
        end
    end

    it("uses row A-T-G-C (2)", check_row("A-T-G-C"))

    it("uses row ATGC", check_row("ATGC"))

    it("uses row A", check_row("A"))

    it("uses row --A-", check_row("--A-"))

    it("uses long row",
        check_row([[
TCACCATTATACAGTTATGGTATGAACTGGGTCTTCAT-AA------AA-AAAAATATTT
TTTTTTGTTTATGCCATCATAGTTGTTCAATTATGCTAGTTT-----------GAATACC
GAGCAAGAGCCACGTGCTTGAAAATCTTGCAAGCACTTTGAGGGGGAGCATTTTGAAAGC
TTAAGTTTGACTCAATAACTGCGATGGTTGAGGGTAAT----------------TT-ATG
-ATATATGACTTGCTTTCATCAAGTATGTCGCGTGATTACTGAAGCTTTCTCTGCCCTGC
ATAATGACCTATAATTATTC-----CAAAAAGCTTACTC
    ]]))
end)

