describe("algo.BlocksWithoutOverlaps", function()
    it("merges blocksets without overlaps (prefers longest)",
    function()
        local model = require 'npge.model'
        local S = model.Sequence
        local F = model.Fragment
        local B = model.Block
        local BS = model.BlockSet
        local s = S("s", "ATAT")
        local b1 = B({F(s, 0, 0, 1)})
        local b2 = B({F(s, 1, 1, 1)})
        local b3 = B({F(s, 0, 1, 1)}) -- covers b1 and b2
        local orig = BS({s}, {b1, b2})
        local added = BS({s}, {b3})
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        assert.equal(BWO(orig, added), BS({s}, {b3}))
    end)

    it("merges blocksets without overlaps (prefers highest)",
    function()
        local model = require 'npge.model'
        local S = model.Sequence
        local F = model.Fragment
        local B = model.Block
        local BS = model.BlockSet
        local s = S("s", "ATAT")
        local b1 = B({F(s, 0, 1, 1)})
        local b2 = B({F(s, 0, 0, 1), F(s, 1, 1, -1)})
        local orig = BS({s}, {b1})
        local added = BS({s}, {b2})
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        assert.equal(BWO(orig, added), BS({s}, {b2}))
    end)

    it("merges blocksets without overlaps (prefers from orig)",
    function()
        local model = require 'npge.model'
        local S = model.Sequence
        local F = model.Fragment
        local B = model.Block
        local BS = model.BlockSet
        local s = S("s", "ATAT")
        local b1 = B({F(s, 0, 1, 1)})
        local b2 = B({F(s, 1, 2, 1)})
        local orig = BS({s}, {b1})
        local added = BS({s}, {b2})
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        assert.equal(BWO(orig, added), BS({s}, {b1}))
    end)

    it("merges blocksets without overlaps (many fragments)",
    function()
        local model = require 'npge.model'
        local S = model.Sequence
        local F = model.Fragment
        local B = model.Block
        local BS = model.BlockSet
        local s = S("s", string.rep('A', 1000))
        local blocks10 = {}
        for start = 0, 990, 10 do
            local fragment = F(s, start, start + 9, 1)
            table.insert(blocks10, B({fragment}))
        end
        local short_block = B({F(s, 0, 1, 1)})
        local orig = BS({s}, {short_block})
        local added = BS({s}, blocks10)
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        assert.equal(BWO(orig, added), added)
    end)
end)
