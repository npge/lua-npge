describe("util.extract_value", function()
    it("extract values from key=value string", function()
        local ev = require 'npge.util.extract_value'
        assert.equal(ev("a=b c=d", "a"), "b")
        assert.equal(ev("abc=123 fre=567", "fre"), "567")
        assert.equal(ev('abc=1 "fre=5 tt=ttt"', "fre"),
            "5 tt=ttt")
    end)
end)
