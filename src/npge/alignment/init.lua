local to_atgcn2 = require 'npge.alignment.to_atgcn_and_gap'

return {
    left = require 'npge.alignment.left',
    anchor = require 'npge.alignment.anchor',
    to_atgcn = require 'npge.alignment.to_atgcn',
    to_atgcn_and_gap = to_atgcn2,
    unwind_row = require 'npge.alignment.unwind_row'
}
