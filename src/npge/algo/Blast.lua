local Blast = {}

function Blast.makeBlastDb(bank_fname, consensus_fname)
    local args = {
        'makeblastdb',
        '-dbtype nucl',
        '-out', bank_fname,
        '-in', consensus_fname,
    }
    -- not os.execute to suppress messages produced by blast
    local f = assert(io.popen(table.concat(args, ' ')))
    f:read('*a')
    f:close()
end

function Blast.makeConsensus(consensus_fname, blockset)
    local write_it = require 'npge.util.write_it'
    local algo = require 'npge.algo'
    write_it(consensus_fname,
        algo.WriteSequencesToFasta(blockset))
end

function Blast.checkNoCollisions(bs1, bs2)
    for seq in bs1:iter_sequences() do
        local test = {[seq] = true}
        local seq2 = bs2:sequence_by_name(seq:name())
        local message = [[Name %s
            corresponds to different sequences
            in query and bank]]
        assert(not seq2 or test[seq2],
            message:format(seq:name()))
    end
end

return Blast
