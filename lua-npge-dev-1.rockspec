package = "lua-npge"
version = "dev-1"
source = {
    url = "git://github.com/starius/lua-npge.git"
}
description = {
    summary = "Nucleotide PanGenome explorer (Lua module)",
    homepage = "https://github.com/starius/lua-npge",
    license = "MIT",
}
dependencies = {
    "lua >= 5.1"
}
build = {
    type = "builtin",
    modules = {
        -- TODO Lua modules
        ['npge.cpp'] = {
            sources = {
                "src/npge/cpp/lua_npge.cpp",
                "src/npge/cpp/model.cpp",
                "src/npge/cpp/throw_assert.cpp",
                "src/npge/cpp/strings.cpp",
                "src/npge/cpp/alignment.cpp",
            },
            libraries = {"stdc++"},
        },
    },
}

