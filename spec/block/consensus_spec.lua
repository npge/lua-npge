-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.consensus", function()
    it("finds consensus of block (100%)", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f = model.Fragment(s, 0, 3, 1)
        local b = model.Block({f, f})
        local consensus = require 'npge.block.consensus'
        assert.equal(consensus(b), "ATAT")
    end)

    local checkConsensus = function(rows, expected_consensus)
        it("gets consensus " .. expected_consensus, function()
            local model = require 'npge.model'
            local for_block = {}
            for i, row in ipairs(rows) do
                local s = model.Sequence('name' .. i, row)
                local f = model.Fragment(s, 0,
                    s:length() - 1, 1)
                table.insert(for_block, {f, row})
            end
            local b = model.Block(for_block)
            local consensus = require 'npge.block.consensus'
            assert.equal(consensus(b), expected_consensus)
        end)
    end

    checkConsensus({
       "ATAT",
    }, "ATAT")

    checkConsensus({
       "ATAT",
       "AT-T",
       "AT-T",
    }, "ATAT")

    checkConsensus({
       "A",
       "T",
       "G",
    }, "A")

    checkConsensus({
       "A",
       "N",
       "N",
    }, "A")

    checkConsensus({
       "A",
       "T",
       "T",
    }, "T")

    checkConsensus({
       "T",
       "T",
       "A",
    }, "T")

    checkConsensus({
       "T",
       "A",
       "T",
    }, "T")

    checkConsensus({
       "T",
       "A",
    }, "A")

    checkConsensus({
[[GCAATGGCGTCAGAGTTTCCATAGTACAATGAATCAGAAGGGAAACAATAAG
TTTTTTAACCATTATACGGTCATGGTATGAACTGAGTTTTCATAAA-GCA]],
[[GCAATGGCATCAGAGTTTCCATAGTACAATGAATTGGAAGTGAAACAATAAG
TTTTTTCACCATTATACAGTTATGGTATGAACTGGGTCTTCATAAAAAAA]],
[[GCAATGGCATCAGAGTTTCCATAGTACAATGAATTGGAAGTGAAACAATCAG
TTTTTTCACCATTATACAGTTATGGTATGAACTGGGTCTTCATAAAAAAA]],
[[GCAATGGCGTCAGAGTTTCCATAGTATAATAAATTGGAAGGAAAACAATTAG
TTTTTTAACTATTATGCAGTCATGGTATGAACTTGGTCTCCATCAAAGCA]],
},
"GCAATGGCATCAGAGTTTCCATAGTACAATGAATTGGAAGTGAAACAATAAG" ..
"TTTTTTAACCATTATACAGTTATGGTATGAACTGGGTCTTCATAAAAAAA")
end)
