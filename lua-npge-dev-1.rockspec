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
    "lua ~> 5.1"
}
build = {
    type = "builtin",
    modules = {
        -- TODO Lua modules
        ['npge.alignment.cidentity'] =
            "src/npge/alignment/identity.c",
        ['npge.alignment.cunwind_row'] =
            "src/npge/alignment/unwind_row.c",
        ['npge.alignment.cmove_identical'] =
            "src/npge/alignment/move_identical.c",
        ['npge.alignment.cleft'] =
            "src/npge/alignment/left.c",
        ['npge.alignment.canchor'] =
            "src/npge/alignment/anchor.c",
        ['npge.alignment.cfindIdentGroups'] =
            "src/npge/alignment/findIdentGroups.c",
        ['npge.cpp'] = {
            sources = {
                "src/npge/cpp/model.cpp",
                "src/npge/cpp/throw_assert.cpp",
                "src/npge/cpp/lua_model.cpp",
                "src/npge/cpp/strings.cpp",
            },
            libraries = {"stdc++"},
        },
    },
}

