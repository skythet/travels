## Dependencies

Tarantool:

    apt-get install tarantool tarantool-dev

Tarantool http:

    apt-get install luarocks
    luarocks install https://raw.githubusercontent.com/tarantool/http/master/http-scm-1.rockspec --local

Turbo:

    apt-get install luajit luarocks git build-essential libssl-dev
    luarocks install turbo

Lua cjson:

    git clone https://github.com/mpx/lua-cjson.git
    cd lua-cjson
    luarocks make --local

Other utils:

    luarocks install luafilesystem --local

## Running

1. Create data dir:

    mkdir data

2. Run app.lua via tarantool:

    tarantool app.lua
