luarocks make --local
export LD_PRELOAD=/lib/x86_64-linux-gnu/libpthread.so.0
busted -c
