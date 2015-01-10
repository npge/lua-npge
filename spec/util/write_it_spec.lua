describe("util.write_it", function()
    it("writes output of iterator to file", function()
        local write_it = require 'npge.util.write_it'
        local it_from_array = require 'npge.util.it_from_array'
        local array = {"123\n", "456\n"}
        local tmp_fname = os.tmpname()
        write_it(tmp_fname, it_from_array(array))
        local tmp_f = io.open(tmp_fname, 'rb')
        local text = tmp_f:read('*a')
        tmp_f:close()
        os.remove(tmp_fname)
        assert.equal(text, '123\n456\n')
    end)
end)
