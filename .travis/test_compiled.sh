luarocks make --local &&
    lua -lnpge.cpp -e'os.exit()' &&
    busted -c
