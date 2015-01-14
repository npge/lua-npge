describe("config", function()
    it("has correct value in config file", function()
        local config = require 'npge.config'
        assert.truthy(config.general.MIN_IDENTITY >= 0)
        assert.truthy(config.general.MIN_IDENTITY <= 1)
        assert.truthy(config.general.MIN_LENGTH >= 1)
        assert.truthy(
            config.general.MIN_END_IDENTICAL_COLUMNS >= 1)
        assert.truthy(type(config.blast.DUST), 'boolean')
        assert.truthy(config.blast.EVALUE >= 0)
        assert.truthy(config.blast.MAX_NS >= 0)
    end)

    local prepare_config = function(conf)
        -- unload 'npge.config'
        package.loaded['npge.config'] = nil
        -- rename npge.conf, if exists
        local file_exists = require 'npge.util.file_exists'
        if file_exists('npge.conf') then
            os.rename('npge.conf', 'npge.conf-bak-by-busted')
        end
        local f = io.open('npge.conf', 'w')
        f:write(conf)
        f:close()
    end

    local restore_config = function()
        -- unload config
        package.loaded['npge.config'] = nil
        -- remove testing npge.conf
        os.remove('npge.conf')
        -- recover previous npge.conf if it exsted
        local file_exists = require 'npge.util.file_exists'
        if file_exists('npge.conf-bak-by-busted') then
            os.rename('npge.conf-bak-by-busted', 'npge.conf')
        end
    end

    it("reads npge.conf", function()
        prepare_config 'general.MIN_LENGTH = 250\n'
        -- load config
        local config = require 'npge.config'
        assert.equal(config.general.MIN_LENGTH, 250)
        -- unload config
        restore_config()
    end)

    local check_error = function(conf)
        return function()
            prepare_config(conf)
            -- load config
            assert.has_error(function()
                local config = require 'npge.config'
            end)
            -- unload config
            restore_config()
            print = orig_print
        end
    end

    it("prints error messages if errors in config (syntax)",
        check_error('a = 1; a++\n'))

    it("prints error messages if errors in config (runtime)",
        check_error('a = 1; a()\n'))

    it("prints error messages if errors in config (type)",
        check_error('general.MIN_LENGTH = true\n'))
end)
