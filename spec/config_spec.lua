describe("config", function()
    it("has correct value in config file", function()
        local config = require 'npge.config'
        assert.truthy(config.general.MIN_IDENTITY >= 0)
        assert.truthy(config.general.MIN_IDENTITY <= 1)
        assert.truthy(config.general.MIN_LENGTH >= 1)
        assert.truthy(
            config.general.MIN_END_IDENTICAL_COLUMNS >= 0)
        assert.truthy(type(config.blast.DUST), 'boolean')
        assert.truthy(config.blast.EVALUE >= 0)
        assert.truthy(config.blast.MAX_NS >= 0)
    end)
end)
