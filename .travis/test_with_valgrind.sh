if [ "$LUA" != "luajit" ]; then
    luarocks make --local CFLAGS="-O0 -g -fPIC"
    make exitless-busted
    valgrind --error-exitcode=1 --leak-check=full \
        --gen-suppressions=all \
        --suppressions=.travis/nsswitch_c_678.supp \
        lua exitless-busted
fi
