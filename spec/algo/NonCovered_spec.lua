describe("algo.NonCovered", function()
    it("finds noncovered parts of sequence (none)", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f = model.Fragment(s, 0, 3, 1)
        local b = model.Block({f})
        local blockset = model.BlockSet({s}, {b})
        local NonCovered = require 'npge.algo.NonCovered'
        local nc = NonCovered(blockset)
        assert.same(nc:sequences(), blockset:sequences())
        assert.same(nc:blocks(), {})
    end)

    it("finds noncovered parts of sequence (5')", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f = model.Fragment(s, 1, 3, 1)
        local b = model.Block({f})
        local blockset = model.BlockSet({s}, {b})
        local NonCovered = require 'npge.algo.NonCovered'
        local nc = NonCovered(blockset)
        assert.same(nc:sequences(), blockset:sequences())
        assert.equal(#nc:blocks(), 1)
        assert.same(nc:blocks()[1]:fragments(),
            {model.Fragment(s, 0, 0, 1)})
    end)

    it("finds noncovered parts of sequence (middle)", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f1 = model.Fragment(s, 0, 0, 1)
        local f2 = model.Fragment(s, 2, 3, 1)
        local b = model.Block({f1, f2})
        local blockset = model.BlockSet({s}, {b})
        local NonCovered = require 'npge.algo.NonCovered'
        local nc = NonCovered(blockset)
        assert.same(nc:sequences(), blockset:sequences())
        assert.equal(#nc:blocks(), 1)
        assert.same(nc:blocks()[1]:fragments(),
            {model.Fragment(s, 1, 1, 1)})
    end)

    it("finds noncovered parts of sequence (3')", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f = model.Fragment(s, 0, 2, 1)
        local b = model.Block({f})
        local blockset = model.BlockSet({s}, {b})
        local NonCovered = require 'npge.algo.NonCovered'
        local nc = NonCovered(blockset)
        assert.same(nc:sequences(), blockset:sequences())
        assert.equal(#nc:blocks(), 1)
        assert.same(nc:blocks()[1]:fragments(),
            {model.Fragment(s, 3, 3, 1)})
    end)

    it("finds noncovered parts of sequence (whole)", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATAT")
        local blockset = model.BlockSet({s}, {})
        local NonCovered = require 'npge.algo.NonCovered'
        local nc = NonCovered(blockset)
        assert.same(nc:sequences(), blockset:sequences())
        assert.equal(#nc:blocks(), 1)
        assert.same(nc:blocks()[1]:fragments(),
            {model.Fragment(s, 0, 3, 1)})
    end)

    it("finds parted noncovered parts of sequence", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATAT")
        local f = model.Fragment(s, 1, 2, 1)
        local b = model.Block({f})
        local blockset = model.BlockSet({s}, {b})
        local NonCovered = require 'npge.algo.NonCovered'
        local nc = NonCovered(blockset)
        assert.same(nc:sequences(), blockset:sequences())
        assert.equal(#nc:blocks(), 1)
        assert.same(nc:blocks()[1]:fragments(),
            {model.Fragment(s, 3, 0, 1)})
    end)

    it("finds noncovered parts of sequence (parted)", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATAT")
        local f = model.Fragment(s, 3, 0, 1)
        local b = model.Block({f})
        local blockset = model.BlockSet({s}, {b})
        local NonCovered = require 'npge.algo.NonCovered'
        local nc = NonCovered(blockset)
        assert.same(nc:sequences(), blockset:sequences())
        assert.equal(#nc:blocks(), 1)
        assert.same(nc:blocks()[1]:fragments(),
            {model.Fragment(s, 1, 2, 1)})
    end)

    it("finds noncovered parts of sequence (overlaps)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 1, 2, 1)
        local b = model.Block({f1, f2})
        local blockset = model.BlockSet({s}, {b})
        local NonCovered = require 'npge.algo.NonCovered'
        local nc = NonCovered(blockset)
        assert.equal(nc, model.BlockSet({s},
            {model.Block({model.Fragment(s, 3, 3, 1)})}))
    end)
end)
