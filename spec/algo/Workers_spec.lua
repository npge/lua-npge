describe("algo.Workers", function()
    it("extracts good blocks in parallel",
    function()
        local BlockSet = require 'npge.model.BlockSet'
        if BlockSet.toRef and BlockSet.fromRef then
            -- AAAAAAAA
            -- ACATTACA
            local config = require 'npge.config'
            local min_len = config.general.MIN_LENGTH
            local good_len = 2 * min_len
            local min_ident = config.general.MIN_IDENTITY
            local orig_WORKERS = config.util.WORKERS
            config.util.WORKERS = 4
            -- ident = good_len / (good_len + middle_len)
            local middle_len = good_len / min_ident - good_len
            middle_len = math.floor(middle_len) + 2
            local length = good_len + middle_len
            local Sequence = require 'npge.model.Sequence'
            local s1 = Sequence('s1', string.rep('A', length))
            local s2 = Sequence('s2',
                string.rep('A', min_len) ..
                string.rep('T', middle_len) ..
                string.rep('A', min_len))
            local Fragment = require 'npge.model.Fragment'
            local f1 = Fragment(s1, 0, s1:length() - 1, 1)
            local f2 = Fragment(s2, 0, s2:length() - 1, 1)
            local Block = require 'npge.model.Block'
            local blocks = {}
            for i = 1, 1000 do
                local block = Block({f1, f2})
                table.insert(blocks, block)
            end
            local blockset = BlockSet({s1, s2}, blocks)
            --
            local ParallelGoodSubblocks = function(bs)
                local Workers = require 'npge.algo.Workers'
                return Workers(bs, 'npge.algo.GoodSubblocks')
            end
            local good_blocks = ParallelGoodSubblocks(blockset)
            assert.truthy(#good_blocks:blocks() >= 1)
            local is_good = require 'npge.block.is_good'
            assert.truthy(is_good(good_blocks:blocks()[1]))
            --
            config.util.WORKERS = orig_WORKERS
        end
    end)
end)
