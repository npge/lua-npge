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

return Blast
