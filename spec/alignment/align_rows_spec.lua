describe("alignment.align_rows", function()
    it("align multiple rows (simple)", function()
        local f = require 'npge.alignment.align_rows'
        assert.same(f({"ATGC"}), {"ATGC"})
    end)

    it("align multiple rows (2 equal sequences)", function()
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGC",
            "ATGC",
        }), {
            "ATGC",
            "ATGC",
        })
    end)

    it("align multiple rows (long gap)", function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        config.alignment.ANCHOR = 4
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCTTTTTTTTTATGC",
            "ATGCATGC",
        }), {
            "ATGCTTTTTTTTTATGC",
            "ATGC---------ATGC",
        })
        --
        config.alignment = orig
    end)

    it("align multiple rows (long gap, 4 rows)", function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        config.alignment.ANCHOR = 4
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCTTATTATTTAATGC",
            "ATGCTTTTTATTTAATGC",
            "ATGCTTTTTTTTAATGC",
            "ATGCATGC",
        }), {
            "ATGCTTATTATTTAATGC",
            "ATGCTTTTTATTTAATGC",
            "ATGCTTTTT-TTTAATGC",
            "ATGC----------ATGC",
        })
        --
        config.alignment = orig
    end)

    it("align multiple rows (long gap, 4 rows, double)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 2
        config.alignment.ANCHOR = 4
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCTCATTATTTAATGCTTATTATTTAATGC",
            "ATGCTCTTTATTTAATGCTTTTTATTTAATGC",
            "ATGCTCTTTTTTAATGCTTTTTTTTAATGC",
            "ATGCATGCATGC",
        }), {
            "ATGCTCATTATTTAATGCTTATTATTTAATGC",
            "ATGCTCTTTATTTAATGCTTTTTATTTAATGC",
            "ATGCTCTTT-TTTAATGCTTTTT-TTTAATGC",
            "ATGC----------ATGC----------ATGC",
        })
        --
        config.alignment = orig
    end)

    it("align multiple rows (#only_left)", function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC",
        }, true), {
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC----------",
        })
        --
        config.alignment = orig
    end)

    it("align multiple rows (#only_left control)", function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC",
        }), {
            "ATGCTTGCTATTTAATGC",
            "ATGC----------ATGC",
        })
        --
        config.alignment = orig
    end)
end)
