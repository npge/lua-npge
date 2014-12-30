local model = require 'npge.model'

describe("model.blockset", function()
    it("creates blockset of one block", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block = model.Block({f1, f2})
        local blockset = model.BlockSet({s}, {block})
        assert.equal(blockset:size(), 1)
        assert.same(blockset:seqs(), {s})
        assert.same(blockset:blocks(), {block})
        --
        local seqs = {}
        for seq in blockset:iter_seqs() do
            table.insert(seqs, seq)
        end
        assert.same(seqs, {s})
        --
        local blocks = {}
        for block in blockset:iter_blocks() do
            table.insert(blocks, block)
        end
        assert.same(blocks, {block})
    end)

    it("creates empty blockset", function()
        local blockset = model.BlockSet({}, {})
        assert.equal(blockset:size(), 0)
        assert.same(blockset:seqs(), {})
        assert.same(blockset:blocks(), {})
    end)

    it("creates a blockset without blocks", function()
        local s = model.Sequence("test_name", "ATAT")
        local blockset = model.BlockSet({s}, {})
        assert.equal(blockset:size(), 0)
        assert.same(blockset:seqs(), {s})
        assert.same(blockset:blocks(), {})
    end)

    it("throws if fragment is on unknown sequence", function()
        assert.has_error(function()
            local s1 = model.Sequence("s1", "ATAT")
            local s2 = model.Sequence("s2", "ATAT")
            local f1 = model.Fragment(s1, 0, 1, 1)
            local f2 = model.Fragment(s1, 3, 2, -1)
            local block = model.Block({f1, f2})
            local blockset = model.BlockSet({s2}, {block})
        end)
    end)

    it("throws if two sequences have same name", function()
        assert.has_error(function()
            local s1 = model.Sequence("s", "ATAT")
            local s2 = model.Sequence("s", "ATAT")
            local blockset = model.BlockSet({s1, s2}, {})
        end)
    end)

    it("creates a blockset with 2 blocks", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block1 = model.Block({f1, f2})
        local block2 = model.Block({f1})
        local blockset = model.BlockSet({s}, {block1, block2})
        assert.equal(blockset:size(), 2)
        assert.same(blockset:seqs(), {s})
        assert.same(blockset:blocks(), {block1, block2})
    end)

end)

