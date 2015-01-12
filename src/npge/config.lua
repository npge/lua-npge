return {
    general = {
        -- Minimum acceptable identity of block (0.9 is 90%)
        MIN_IDENTITY = 0.9,

        -- Minimum acceptable length of fragment (b.p.)
        MIN_LENGTH = 100,

        -- Minimum number of end identical and gapless  cols
        MIN_END_IDENTICAL_COLUMNS = 3,
    },
    blast = {
        -- Filter out low complexity regions
        DUST = false,

        -- E-value filter for blast
        EVALUE = 0.001,

        -- Maximum number of subsequent N's in consensus
        MAX_NS = 3,
    }
}
