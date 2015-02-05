local model = require 'npge.model'

describe("model.blockset", function()
    it("creates blockset of one block", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block = model.Block({f1, f2})
        local blockset = model.BlockSet({s}, {block})
        assert.equal(blockset:is_partition(), true)
        assert.equal(blockset:size(), 1)
        assert.same(blockset:sequences(), {s})
        assert.same(blockset:blocks(), {block})
        --
        local seqs = {}
        for seq in blockset:iter_sequences() do
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
        assert.same(blockset:sequences(), {})
        assert.same(blockset:blocks(), {})
        assert.equal(blockset:is_partition(), true)
    end)

    it("blockset's type is 'BlockSet'", function()
        local blockset = model.BlockSet({}, {})
        assert.equal(blockset:type(), 'BlockSet')
    end)

    it("creates a blockset without blocks", function()
        local s = model.Sequence("test_name", "ATAT")
        local blockset = model.BlockSet({s}, {})
        assert.equal(blockset:size(), 0)
        assert.same(blockset:sequences(), {s})
        assert.same(blockset:blocks(), {})
        assert.equal(blockset:is_partition(), false)
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
        assert.same(blockset:sequences(), {s})
        assert.same(blockset:blocks(), {block1, block2})
        assert.equal(blockset:is_partition(), false)
    end)

    it("finds overlapping fragments", function()
        local s = model.Sequence("genome&chr&c", "ATAT")
        local f1 = model.Fragment(s, 0, 3, -1)
        local f2 = model.Fragment(s, 1, 1, 1)
        local block1 = model.Block({f1, f2})
        local block2 = model.Block({f1})
        local blockset = model.BlockSet({s}, {block1, block2})
        assert.same(blockset:overlapping_fragments(
            model.Fragment(s, 2, 2, 1)), {})
        assert.same(blockset:overlapping_fragments(
            model.Fragment(s, 0, 0, -1)), {f1})
        local toset = function(x)
            local set = {}
            for _, item in ipairs(x) do
                set[item] = true
            end
            return set
        end
        assert.same(toset(blockset:overlapping_fragments(
            model.Fragment(s, 0, 1, -1))), toset({f1, f2}))
        assert.same(toset(blockset:overlapping_fragments(
            model.Fragment(s, 0, 1, 1))), toset({f1, f2}))
    end)

    it("finds next and prev fragments (circular)", function()
        local s = model.Sequence("genome&chr&c", "ATAT")
        local f1 = model.Fragment(s, 0, 3, -1)
        local f2 = model.Fragment(s, 1, 1, 1)
        local f3 = model.Fragment(s, 2, 2, -1)
        local block1 = model.Block({f1, f2, f3})
        local blockset = model.BlockSet({s}, {block1})
        assert.equal(blockset:next(f1), f2)
        assert.equal(blockset:next(f2), f3)
        assert.equal(blockset:next(f3), f1)
        assert.equal(blockset:prev(f1), f3)
        assert.equal(blockset:prev(f3), f2)
        assert.equal(blockset:prev(f2), f1)
    end)

    it("finds next and prev fragments (circular 2)", function()
        local s = model.Sequence("genome&chr&c", "ATAT")
        local f1 = model.Fragment(s, 0, 0, -1)
        local f2 = model.Fragment(s, 1, 1, 1)
        local f3 = model.Fragment(s, 2, 3, 1)
        local block1 = model.Block({f1, f2, f3})
        local blockset = model.BlockSet({s}, {block1})
        assert.equal(blockset:next(f1), f2)
        assert.equal(blockset:next(f2), f3)
        assert.equal(blockset:next(f3), f1)
        assert.equal(blockset:prev(f1), f3)
        assert.equal(blockset:prev(f3), f2)
        assert.equal(blockset:prev(f2), f1)
    end)

    it("finds next and prev fragments (linear)", function()
        local s = model.Sequence("genome&chr&l", "ATAT")
        local f1 = model.Fragment(s, 0, 0, -1)
        local f2 = model.Fragment(s, 1, 1, 1)
        local f3 = model.Fragment(s, 2, 3, 1)
        local block1 = model.Block({f1, f2, f3})
        local blockset = model.BlockSet({s}, {block1})
        assert.equal(blockset:next(f1), f2)
        assert.equal(blockset:next(f2), f3)
        assert.equal(blockset:next(f3), nil)
        assert.equal(blockset:prev(f1), nil)
        assert.equal(blockset:prev(f3), f2)
        assert.equal(blockset:prev(f2), f1)
    end)

    it("checks if it has a sequence", function()
        local s1 = model.Sequence("genome1&chr&c", "ATAT")
        local s2 = model.Sequence("genome2&chr&c", "ATAT")
        local blockset = model.BlockSet({s1}, {})
        assert.truthy(blockset:has_sequence(s1))
        assert.falsy(blockset:has_sequence(s2))
    end)

    it("gets sequence by name", function()
        local s1 = model.Sequence("s1", "ATAT")
        local s2 = model.Sequence("s2", "ATAT")
        local blockset = model.BlockSet({s1}, {})
        assert.equal(blockset:sequence_by_name("s1"), s1)
        assert.equal(blockset:sequence_by_name("s2"), nil)
    end)

    it("gets block by fragment", function()
        local s = model.Sequence("s", "ATAT")
        local f1 = model.Fragment(s, 0, 0, 1)
        local f2 = model.Fragment(s, 1, 1, 1)
        local block1 = model.Block({f1})
        local block2 = model.Block({f2})
        local blockset = model.BlockSet({s}, {block1, block2})
        assert.equal(blockset:block_by_fragment(f1), block1)
        assert.equal(blockset:block_by_fragment(f2), block2)
        local f3 = model.Fragment(s, 1, 1, 1)
        assert.equal(blockset:block_by_fragment(f3), nil)
    end)

    it("gets fragments located on sequence", function()
        local s1 = model.Sequence("s1", "ATAT")
        local s2 = model.Sequence("s2", "ATAT")
        local f1 = model.Fragment(s1, 0, 0, 1)
        local f2 = model.Fragment(s1, 1, 1, 1)
        local f3 = model.Fragment(s2, 1, 1, 1)
        local b1 = model.Block({f1})
        local b2 = model.Block({f2, f3})
        local blockset = model.BlockSet({s1, s2}, {b1, b2})
        assert.same(blockset:fragments(s1), {f1, f2})
        assert.same(blockset:fragments(s2), {f3})
    end)

    it("gets fragments located on sequence (iter)", function()
        local arr = require('npge.util.clone').array_from_it
        local s1 = model.Sequence("s1", "ATAT")
        local s2 = model.Sequence("s2", "ATAT")
        local f1 = model.Fragment(s1, 0, 0, 1)
        local f2 = model.Fragment(s1, 1, 1, 1)
        local f3 = model.Fragment(s2, 1, 1, 1)
        local b1 = model.Block({f1})
        local b2 = model.Block({f2, f3})
        local blockset = model.BlockSet({s1, s2}, {b1, b2})
        assert.same(arr(blockset:iter_fragments(s1)), {f1, f2})
        assert.same(arr(blockset:iter_fragments(s2)), {f3})
    end)

    it("gets fragments located on sequence (parted)", function()
        local s1 = model.Sequence("g&c&c", "ATAT")
        local f1 = model.Fragment(s1, 1, 2, 1)
        local f2 = model.Fragment(s1, 3, 0, 1) -- parted
        local b1 = model.Block({f1, f2})
        local blockset = model.BlockSet({s1}, {b1})
        local it = blockset:iter_fragments(s1)
        local expected = {
            {f2, model.Fragment(s1, 0, 0, 1)},
            {f1, f1},
            {f2, model.Fragment(s1, 3, 3, 1)},
        }
        for _, ff in ipairs(expected) do
            local fragment, subfragment = it()
            assert.same(fragment, ff[1])
            assert.same(subfragment, ff[2])
        end
    end)

    it("compares sets of sequences", function()
        local s1 = model.Sequence("g1&c&c", "ATAT")
        local s1a = model.Sequence("g1&c&c", "ATAT")
        local s1b = model.Sequence("g1&c&c", "ATATA")
        local s2 = model.Sequence("g2&c&c", "ATAT")
        local BS = function(...)
            return model.BlockSet({...}, {})
        end
        assert.truthy(BS(s1):same_sequences(BS(s1)))
        assert.falsy(BS(s1):same_sequences(BS(s1, s2)))
        assert.truthy(BS(s1, s2):same_sequences(BS(s1, s2)))
        assert.truthy(BS(s2, s1):same_sequences(BS(s1, s2)))
        assert.falsy(BS(s2):same_sequences(BS(s1)))
        assert.truthy(BS(s1):same_sequences(BS(s1a)))
        assert.truthy(BS(s1):same_sequences(BS(s1b)))
    end)

    it("compares blocksets", function()
        local s1 = model.Sequence("g1&c&c", "ATAT")
        local s2 = model.Sequence("g2&c&c", "ATAT")
        local f1 = model.Fragment(s1, 0, 0, 1)
        local f1a = model.Fragment(s1, 1, 1, 1)
        local f2 = model.Fragment(s2, 0, 0, 1)
        local B = function(...)
            return model.Block({...})
        end
        local BS = model.BlockSet
        assert.equal(BS({s1},{}), BS({s1}, {}))
        assert.not_equal(BS({s1},{}), BS({s2}, {}))
        assert.equal(BS({s1},{B(f1)}), BS({s1}, {B(f1)}))
        assert.not_equal(BS({s1}, {B(f1)}), BS({s1}, {}))
        assert.equal(BS({s1, s2}, {B(f1), B(f2)}),
            BS({s1, s2}, {B(f1), B(f2)}))
        assert.not_equal(BS({s1, s2}, {B(f1), B(f2)}),
            BS({s1, s2}, {B(f1), B(f1)}))
        assert.not_equal(BS({s1, s2}, {B(f1), B(f2)}),
            BS({s1, s2}, {B(f1)}))
        assert.equal(BS({s1, s2}, {B(f1), B(f2)}),
            BS({s1, s2}, {B(f2), B(f1)}))
        assert.equal(BS({s1}, {B(f1), B(f1a)}),
            BS({s1}, {B(f1), B(f1a)}))
        assert.not_equal(BS({s1, s2}, {B(f1, f1a), B(f2)}),
            BS({s1, s2}, {B(f1), B(f1a, f2)}))
        assert.equal(BS({s1, s2}, {B(f1), B(f1a)}),
            BS({s1, s2}, {B(f1), B(f1a)}))
        assert.equal(BS({s1, s2}, {B(f1), B(f1a), B(f2)}),
            BS({s1, s2}, {B(f1), B(f1a), B(f2)}))
        assert.not_equal(BS({s1, s2}, {B(f1), B(f1), B(f2)}),
            BS({s1, s2}, {B(f1), B(f1a), B(f2)}))
        -- method BlockSet:cmp
        local status, reason =
            BS({s1, s2}, {B(f1), B(f1), B(f2)}):cmp(
                BS({s1, s2}, {B(f1), B(f1a), B(f2)}))
        assert.falsy(status)
        assert.truthy(reason)
    end)

    it("compares blocksets (different objects)", function()
        local B = function(...)
            return model.Block({...})
        end
        local BS = model.BlockSet
        local make_bs = function()
            local s1 = model.Sequence("g1&c&c", "ATAT")
            local s2 = model.Sequence("g2&c&c", "ATAT")
            local f1 = model.Fragment(s1, 0, 0, 1)
            local f1a = model.Fragment(s1, 1, 1, 1)
            local f2 = model.Fragment(s2, 0, 0, 1)
            return BS({s1, s2}, {B(f1, f2), B(f1a)})
        end
        assert.equal(make_bs(), make_bs())
    end)

    it("makes string representation of blockset", function()
        local s1 = model.Sequence("g&c&c", "ATAT")
        local f1 = model.Fragment(s1, 1, 2, 1)
        local f2 = model.Fragment(s1, 3, 0, 1) -- parted
        local b1 = model.Block({f1, f2})
        local blockset = model.BlockSet({s1}, {b1})
        assert.truthy(tostring(blockset))
    end)
end)

