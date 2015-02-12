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
    local util = require 'npge.util'
    assert(util.file_exists(bank_fname .. '.nhr'))
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

function Blast.blastnCmd(bank_fname, query_fname, options)
    local config = require 'npge.config'
    local evalue = options.evalue or config.blast.EVALUE
    local workers = options.workers or config.util.WORKERS
    local dust = options.dust or config.blast.DUST
    local dust = dust and 'yes' or 'no'
    local args = {
        'blastn',
        '-task blastn',
        '-db', bank_fname,
        '-query', query_fname,
        '-evalue', tostring(evalue),
        '-num_threads', workers,
        '-dust', dust,
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
