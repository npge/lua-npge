if [ "$LUA" != "luajit" ]; then
    luarocks make --local CFLAGS="-O0 -g -fPIC"
    make exitless-busted
    valgrind --error-exitcode=1 --leak-check=full \
        lua exitless-busted
fi
