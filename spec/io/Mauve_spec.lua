-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.io.ReadMauve1File and npge.io.ReadMauveBbcolsFile",
function()

    it("reads XMFA and bbcols files by progressiveMauve #mosses",
    function()
        local bs_with_seqs = dofile('spec/sample_pangenome.lua')

        local sequences_names = {
            'ANOAT&mit1&c',
            'ANORU&mit1&c',
            'ATRAN&mit1&c',
        }

        local ReadMauve1File = require 'npge.io.ReadMauve1File'
        local global_blocks = ReadMauve1File(
            io.lines('spec/mauve/mosses.xmfa'),
            bs_with_seqs,
            sequences_names
        )

        local ReadMauveBbcolsFile = require 'npge.io.ReadMauveBbcolsFile'
        local conserved_blocks = ReadMauveBbcolsFile(
            io.lines('spec/mauve/mosses.bbcols'),
            global_blocks,
            sequences_names
        )

        assert.equal(global_blocks:size(), 10)
        assert.equal(conserved_blocks:size(), 208)
    end)

end)
