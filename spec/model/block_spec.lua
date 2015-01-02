local model = require 'npge.model'

describe("model.block", function()
    it("cleans all except ATGCN and gaps", function()
        local Block = model.Block
        local f = Block.to_atgcn_and_gap
        assert.are.equal(f("a T g"), "ATG")
        assert.are.equal(f("a T-g"), "AT-G")
        assert.are.equal(f("a T--\ng"), "AT--G")
    end)

    it("creates block without rows", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block = model.Block({f1, f2})
        assert.are.equal(block:size(), 2)
        assert.are.equal(block:length(), 2)
    end)

    it("creates block with rows", function()
        local s = model.Sequence("test_name", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local block = model.Block({
            {f1, 'AAT'},
            {f2, 'A-T'},
        })
        assert.are.equal(block:size(), 2)
        assert.are.equal(block:length(), 3)
        assert.are.equal(block:text(f1), 'AAT')
        assert.are.equal(block:text(f2), 'A-T')
        assert.are.equal(block:block2fragment(f1, 0), 0)
        assert.are.equal(block:block2fragment(f1, 1), 1)
        assert.are.equal(block:block2fragment(f1, 2), 2)
        assert.are.equal(block:block2fragment(f2, 0), 0)
        assert.are.equal(block:block2fragment(f2, 1), -1)
        assert.are.equal(block:block2fragment(f2, 2), 1)
        assert.are.equal(block:fragment2block(f1, 0), 0)
        assert.are.equal(block:fragment2block(f1, 1), 1)
        assert.are.equal(block:fragment2block(f1, 2), 2)
        assert.are.equal(block:fragment2block(f2, 0), 0)
        assert.are.equal(block:fragment2block(f2, 1), 2)
        assert.are.equal(block:block2left(f2, 0), 0)
        assert.are.equal(block:block2left(f2, 1), 0)
        assert.are.equal(block:block2left(f2, 2), 1)
        assert.are.equal(block:block2right(f2, 0), 0)
        assert.are.equal(block:block2right(f2, 1), 1)
        assert.are.equal(block:block2right(f2, 2), 1)
        assert.are.equal(block:block2nearest(f2, 0), 0)
        local nearest = block:block2nearest(f2, 1)
        assert(nearest == 0 or nearest == 1)
        assert.are.equal(block:block2nearest(f2, 2), 1)
    end)

    it("block2nearest with unique result", function()
        local s = model.Sequence("test_name", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local block = model.Block({
            {f1, 'A----AT'},
        })
        assert.are.equal(block:block2nearest(f1, 0), 0)
        assert.are.equal(block:block2nearest(f1, 1), 0)
        assert.are.equal(block:block2nearest(f1, 2), 0)
        assert.are.equal(block:block2nearest(f1, 3), 1)
        assert.are.equal(block:block2nearest(f1, 4), 1)
        assert.are.equal(block:block2nearest(f1, 5), 1)
        assert.are.equal(block:block2nearest(f1, 6), 2)
    end)

    it("throws on poor formed blocks", function()
        local s = model.Sequence("test_name", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        assert.has_error(function()
            local block = model.Block({})
        end)
        assert.has_error(function()
            local block = model.Block({
                f1,
                {f2, 'AT'},
            })
        end)
        assert.has_error(function()
            local block = model.Block({
                {f1, 'AAT'},
                {f2, 'AT'},
            })
        end)
        assert.has_error(function()
            local block = model.Block({
                {f1, ''},
                {f2, ''},
            })
        end)
        assert.has_error(function()
            local block = model.Block({
                {f1, ''},
                {f2, ''},
            })
        end)
    end)

    it("gets fragments of block", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local ff1 = {f1, f2}
        local block = model.Block(ff1)
        local ff2 = block:fragments()
        table.sort(ff1)
        table.sort(ff2)
        assert.are.same(ff1, ff2)
    end)

    it("iterate fragments of block", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local ff1 = {f1, f2}
        local block = model.Block(ff1)
        local ff2 = {}
        for f in block:iter_fragments() do
            table.insert(ff2, f)
        end
        table.sort(ff1)
        table.sort(ff2)
        assert.are.same(ff1, ff2)
    end)
end)

