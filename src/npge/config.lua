local config = {
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
    },

    alignment = {
        -- Min number of equal columns around single mismatch
        MISMATCH_CHECK = 1,

        -- Min number of equal columns around single mismatch
        GAP_CHECK = 2,

        -- Min equal aligned part
        ANCHOR = 7,
    },

    util = {
        -- Number of workers for concurrent tasks
        WORKERS = 1,
    },
}

local update_keys = function(env)
    for section_name, section in pairs(config) do
        if env[section_name] then
            local env_section = env[section_name]
            for name, value in pairs(env_section) do
                if type(value) == type(section[name]) then
                    section[name] = value
                else
                    local msg = 'Ignore %s.%s from npge.conf'
                    error(msg:format(section_name, name))
                end
            end
        end
    end
end

local file_exists = require 'npge.util.file_exists'
if file_exists('npge.conf') then
    local conf_file = io.open('npge.conf')
    local conf = conf_file:read('*a')
    conf_file:close()
    local sandbox = require 'npge.util.sandbox'
    local env = {}
    for section_name, section in pairs(config) do
        env[section_name] = {}
    end
    local conf_sandboxed, message = sandbox(env, conf)
    if conf_sandboxed then
        local status = pcall(conf_sandboxed)
        if status then
            update_keys(env)
        else
            error('Failed to run commands found in config')
        end
    else
        error('Failed to read config: ' .. message)
    end
end

return config
