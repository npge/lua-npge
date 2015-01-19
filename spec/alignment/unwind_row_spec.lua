describe("alignment.unwind_row", function()
    it("unwinds row on consensus using a row on original",
    function()
        local unwind_row = require 'npge.alignment.unwind_row'
        assert.equal(unwind_row('AAA', 'AAA'), 'AAA')
        assert.equal(unwind_row('A-AA', 'AAA'), 'A-AA')
        assert.equal(unwind_row('ATGC', 'ATGC'), 'ATGC')
        assert.equal(unwind_row('ATGC', 'AT-C'), 'AT-C')
        assert.equal(unwind_row('A-TGC', 'AT-C'), 'A-T-C')
    end)
end)
