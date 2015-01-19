describe("alignment.join", function()
    it("joins several alignments", function()
        local join = require 'npge.alignment.join'
        assert.same(join({
            "ATGC",
        }), {
            "ATGC",
        })
        assert.same(join({
            "ATGC",
            "AT-C",
        }), {
            "ATGC",
            "AT-C",
        })
        assert.same(join({
            "ATGC",
            "AT-C",
        }, {
            "AT",
            "AT",
        }), {
            "ATGCAT",
            "AT-CAT",
        })
        assert.same(join({
            "ATGC",
            "AT-C",
        }, {
            "AT",
            "AT",
        }, {
            "GA",
            "TA",
        }), {
            "ATGCATGA",
            "AT-CATTA",
        })
        assert.has_error(function()
            join({
                "ATGC",
                "AT-",
            })
        end)
        assert.has_error(function()
            join({
                "ATGC",
                "AT-C",
            }, {
                "ATGC",
            })
        end)
    end)
end)
