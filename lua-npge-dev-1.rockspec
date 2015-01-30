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
        ['npge.model.cRow'] = "src/npge/model/Row.c",
        ['npge.model.cFragment'] = "src/npge/model/Fragment.c",
        ['npge.model.cSequenceText'] =
            "src/npge/model/SequenceText.c",
        ['npge.alignment.cidentity'] =
            "src/npge/alignment/identity.c",
        ['npge.alignment.cunwind_row'] =
            "src/npge/alignment/unwind_row.c",
        ['npge.alignment.cto_atgcn_and_gap'] =
            "src/npge/alignment/to_atgcn_and_gap.c",
        ['npge.alignment.cto_atgcn'] =
            "src/npge/alignment/to_atgcn.c",
        ['npge.alignment.ccomplement'] =
            "src/npge/alignment/complement.c",
        ['npge.alignment.cmove_identical'] =
            "src/npge/alignment/move_identical.c",
        ['npge.alignment.cleft'] =
            "src/npge/alignment/left.c",
    },
}

