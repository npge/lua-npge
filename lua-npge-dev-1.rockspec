-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

package = "lua-npge"
version = "dev-1"
source = {
    url = "git://github.com/npge/lua-npge.git"
}
description = {
    summary = "Nucleotide PanGenome explorer (Lua module)",
    homepage = "https://github.com/npge/lua-npge",
    license = "MIT",
}
dependencies = {
    "lua >= 5.1",
    "alnbox",
    "luaposix",
}
 external_dependencies = {
    BOOST = {
        header = "boost/foreach.hpp"
    }
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
            incdirs = {"$(BOOST_INCDIR)"},
        },
    },
}

