## Dependencies

Tarantool:

    apt-get install tarantool tarantool-dev

Tarantool http:

    apt-get install luarocks
    luarocks install https://raw.githubusercontent.com/tarantool/http/master/http-scm-1.rockspec --local

## Running

1. Create data dir:

    mkdir data

2. Run app.lua via tarantool:

    tarantool app.lua
