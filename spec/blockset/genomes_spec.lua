describe("blockset.genomes", function()
    local sorted = function(x)
        table.sort(x)
        return x
    end

    it("gets a list of genomes of a blockset", function()
        local model = require 'npge.model'
        local bs = model.BlockSet({
            model.Sequence("genome1&chr1&c", "ATAT"),
            model.Sequence("genome2&chr1&c", "ATAT"),
        }, {})
        local genomes = require 'npge.blockset.genomes'
        local gg1 = genomes(bs)
        local gg2 = {'genome1', 'genome2'}
        assert.same(sorted(gg1), sorted(gg2))
    end)

    it("throws if sequence name does not contain genome",
    function()
        assert.has_error(function()
            local model = require 'npge.model'
            local bs = model.BlockSet({
                model.Sequence("genome1chr1c", "ATAT"),
                model.Sequence("genome2chr1c", "ATAT"),
            }, {})
            local genomes = require 'npge.blockset.genomes'
            local gg1 = genomes(bs)
        end)
    end)
end)
