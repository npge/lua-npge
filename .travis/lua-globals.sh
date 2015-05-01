#!/bin/bash

(for f in $@; do luac -l -p $f; done) | egrep ETGLOBAL | \
    awk '{print $7}' | \
    ( ! egrep -wv \
    "string|xpcall|package|tostring|print|os|unpack|require|getfenv|setmetatable|next|assert|tonumber|io|rawequal|collectgarbage|getmetatable|module|rawset|math|debug|pcall|table|newproxy|type|coroutine|_G|select|gcinfo|pairs|rawget|loadstring|ipairs|_VERSION|dofile|setfenv|load|error|loadfile" )
