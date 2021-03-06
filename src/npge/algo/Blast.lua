-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local Blast = {}

function Blast.makeBlastDb(bank_fname, consensus_fname)
    local nullName = require 'npge.util.nullName'
    local args = {
        'makeblastdb',
        '-dbtype nucl',
        '-out', bank_fname,
        '-in', consensus_fname,
        '-logfile', nullName(),
    }
    local cmd = table.concat(args, ' ')
    os.execute(cmd)
    local util = require 'npge.util'
    assert(util.fileExists(bank_fname .. '.nhr'))
end

function Blast.makeConsensus(consensus_fname, blockset)
    local npge = require 'npge'
    npge.util.writeIt(consensus_fname,
        npge.io.WriteSequencesToFasta(blockset))
end

function Blast.checkNoCollisions(bs1, bs2)
    for seq in bs1:iterSequences() do
        local test = {[seq] = true}
        local seq2 = bs2:sequenceByName(seq:name())
        local message = [[Name %s
            corresponds to different sequences
            in query and bank]]
        assert(not seq2 or test[seq2],
            message:format(seq:name()))
    end
end

function Blast.blastnCmd(bank_fname, query_fname)
    local config = require 'npge.config'
    local nullName = require 'npge.util.nullName'
    local args = {
        'blastn',
        '-task blastn',
        '-db', bank_fname,
        '-query', query_fname,
        '-evalue', tostring(config.blast.EVALUE),
        '-dust', (config.blast.DUST and 'yes' or 'no'),
        '2>', nullName(),
    }
    return table.concat(args, ' ')
end

function Blast.bankCleanup(bank_fname)
    os.remove(bank_fname)
    os.remove(bank_fname .. '.nhr')
    os.remove(bank_fname .. '.nin')
    os.remove(bank_fname .. '.nsq')
end

return Blast
