-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local config = {
    general = {
        MIN_IDENTITY = {0.9,
        "Minimum acceptable block identity (0.9 is 90%)"},

        MIN_LENGTH = {100,
        "Minimum acceptable length of fragment (b.p.)"},

        FRAME_LENGTH = {100,
        "Length of alignment checker frame (b.p.)"},

        MIN_END = {10,
        "Minimum number of end good columns"},
    },

    blast = {
        DUST = {false, "Filter out low complexity regions"},

        EVALUE = {0.001, "E-value filter for blast"},
    },

    alignment = {
        MISMATCH_CHECK = {1,
        "Min number of equal columns around single mismatch"},

        GAP_CHECK = {2,
        "Min number of equal columns around single gap"},

        ANCHOR = {7, "Min equal aligned part"},
    },

    util = {
        WORKERS = {1, "Number of parallel workers"},
    },
}

-- move descriptions to table about
local about = {}
for section_name, section in pairs(config) do
    about[section_name] = {}
    local names = {}
    for name, value_and_desc in pairs(section) do
        table.insert(names, name)
    end
    for _, name in ipairs(names) do
        local value = section[name][1]
        local desc = section[name][2]
        section[name] = value
        about[section_name][name] = desc
    end
end

local function updateKeys(_, env)
    local revert = {}
    for section_name, section in pairs(config) do
        if env[section_name] then
            local revert_section = {}
            revert[section_name] = revert_section
            local env_section = env[section_name]
            for name, value in pairs(env_section) do
                if type(value) == type(section[name]) then
                    revert_section[name] = section[name]
                    section[name] = value
                else
                    local msg = 'Ignore %s.%s from npge.conf'
                    error(msg:format(section_name, name))
                end
            end
        end
    end
    return function()
        updateKeys(nil, revert)
    end
end

local function loadConfig(_, conf)
    local sandbox = require 'npge.util.sandbox'
    local env = {}
    for section_name, section in pairs(config) do
        env[section_name] = {}
    end
    local conf_sandboxed, message = sandbox(env, conf)
    if conf_sandboxed then
        local status = pcall(conf_sandboxed)
        if status then
            updateKeys(nil, env)
        else
            error('Failed to run commands found in config')
        end
    else
        error('Failed to read config: ' .. message)
    end
end

setmetatable(config, {
    __index = {
        updateKeys = updateKeys,
        about = about,
        save = require 'npge.util.configGenerator',
        load = loadConfig,
    }
})

local fileExists = require 'npge.util.fileExists'
if fileExists('npge.conf') then
    local conf_file = io.open('npge.conf')
    local conf = conf_file:read('*a')
    conf_file:close()
    loadConfig(nil, conf)
end

return config
