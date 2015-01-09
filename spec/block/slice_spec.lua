describe("block.slice", function()
    it("slices vertical parts of block", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local block = model.Block({
            {f1, 'AAT'},
            {f2, 'A-T'},
        })
        local slice = require 'npge.block.slice'
        local block_slice = slice(block, 1, 2)
        local block_slice_exp = model.Block({
            {model.Fragment(s, 1, 2, 1), 'AT'},
            {model.Fragment(s, 3, 3, -1), '-T'},
        })
        assert.are.equal(block_slice, block_slice_exp)
    end)

    it("slices vertical parts of block (parted)", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATAT")
        local f1 = model.Fragment(s, 0, 2, -1)
        local f2 = model.Fragment(s, 4, 3, 1)
        local block = model.Block({
            {f1, 'TA-TA'},
            {f2, 'TAATA'},
        })
        local slice = require 'npge.block.slice'
        local block_slice = slice(block, 0, 3)
        local block_slice_exp = model.Block({
            {model.Fragment(s, 0, 3, -1), 'TA-T'},
            {model.Fragment(s, 4, 2, 1), 'TAAT'},
        })
        assert.are.equal(block_slice, block_slice_exp)
    end)

    it("slices vertical parts of block (row)", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATAT")
        local f1 = model.Fragment(s, 0, 2, -1)
        local f2 = model.Fragment(s, 4, 3, 1)
        local block = model.Block({
            {f1, 'TA-TA'},
            {f2, 'TAATA'},
        })
        local slice = require 'npge.block.slice'
        local block_slice = slice(block, 0, 3, 'T-AAT')
        local block_slice_exp = model.Block({
            {model.Fragment(s, 0, 3, -1), 'T-A-T'},
            {model.Fragment(s, 4, 2, 1), 'T-AAT'},
        })
        assert.are.equal(block_slice, block_slice_exp)
    end)
end)
