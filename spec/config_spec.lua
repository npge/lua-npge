-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.config", function()
    it("has correct value in config file", function()
        local config = require 'npge.config'
        assert.truthy(config.general.MIN_IDENTITY >= 0)
        assert.truthy(config.general.MIN_IDENTITY <= 1)
        assert.truthy(config.general.MIN_LENGTH >= 1)
        assert.truthy(config.general.MIN_END >= 1)
        assert.truthy(type(config.blast.DUST), 'boolean')
        assert.truthy(config.blast.EVALUE >= 0)
        assert.truthy(config.alignment.MISMATCH_CHECK >= 1)
        assert.truthy(config.alignment.GAP_CHECK >= 1)
        assert.truthy(config.alignment.ANCHOR >= 1)
        --
        assert.truthy(config.about.general.MIN_IDENTITY)
        assert.truthy(config.about.general.MIN_LENGTH)
        assert.truthy(config.about.general.MIN_END)
        assert.truthy(config.about.blast.EVALUE)
    end)

    local function prepareConfig(conf)
        -- unload 'npge.config'
        package.loaded['npge.config'] = nil
        -- rename npge.conf, if exists
        local fileExists = require 'npge.util.fileExists'
        if fileExists('npge.conf') then
            os.rename('npge.conf', 'npge.conf-bak-by-busted')
        end
        local f = io.open('npge.conf', 'w')
        f:write(conf)
        f:close()
    end

    local function restoreConfig()
        -- unload config
        package.loaded['npge.config'] = nil
        -- remove testing npge.conf
        os.remove('npge.conf')
        -- recover previous npge.conf if it existed
        local fileExists = require 'npge.util.fileExists'
        if fileExists('npge.conf-bak-by-busted') then
            os.rename('npge.conf-bak-by-busted', 'npge.conf')
        end
    end

    it("reads npge.conf", function()
        prepareConfig 'general.MIN_LENGTH = 250\n'
        -- load config
        local config = require 'npge.config'
        assert.equal(config.general.MIN_LENGTH, 250)
        -- unload config
        restoreConfig()
    end)

    it("reads npge.conf produced by C++ NPGe", function()
        prepareConfig [[
            MIN_LENGTH = 250
            MIN_IDENTITY = Decimal('0.9')
        ]]
        -- load config
        local config = require 'npge.config'
        -- unload config
        restoreConfig()
    end)

    local function checkError(conf)
        return function()
            prepareConfig(conf)
            -- load config
            assert.has_error(function()
                local config = require 'npge.config'
            end)
            -- unload config
            restoreConfig()
        end
    end

    it("prints error messages if errors in config (syntax)",
        checkError('a = 1; a++\n'))

    it("prints error messages if errors in config (runtime)",
        checkError('a = 1; a()\n'))

    it("prints error messages if errors in config (type)",
        checkError('general.MIN_LENGTH = true\n'))

    it("apply and revert change", function()
        local config = require 'npge.config'
        local orig = config.general.MIN_LENGTH
        local revert = config:updateKeys({
            general = {MIN_LENGTH = orig + 1}
        })
        assert.equal(config.general.MIN_LENGTH, orig + 1)
        revert()
        assert.equal(config.general.MIN_LENGTH, orig)
    end)

    it("can't change updateKeys", function()
        prepareConfig 'updateKeys = 42\n'
        -- load config
        local config = require 'npge.config'
        assert.not_equal(config.updateKeys, 42)
        -- unload config
        restoreConfig()
    end)

    it("can't call updateKeys",
        checkError('updateKeys()\n'))

    it("serializes and parses the config", function()
        local config = require 'npge.config'
        local revert = config:updateKeys {
            general = {MIN_LENGTH=200},
        }
        local conf = config:save()
        assert.equal(config.general.MIN_LENGTH, 200)
        revert()
        assert.equal(config.general.MIN_LENGTH, 100)
        config:load(conf)
        assert.equal(config.general.MIN_LENGTH, 200)
        revert()
        assert.equal(config.general.MIN_LENGTH, 100)
    end)
end)
