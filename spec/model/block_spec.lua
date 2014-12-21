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
        pending(function()
            assert.has_error(function()
                local block = model.Block({
                    {f1, ''},
                    {f2, ''},
                })
            end)
        end)
    end)
end)

