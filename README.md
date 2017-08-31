Solution for https://highloadcup.ru/round/1/

## Dependencies

Tarantool:

    apt-get install tarantool tarantool-dev

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

1. Build docker container:

    docker build -t travels .

2. Run script:

    ./run.sh /path/to/train/data
