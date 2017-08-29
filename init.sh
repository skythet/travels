#!/bin/bash

mkdir -p /srv/data
unzip /tmp/data/data.zip -d /srv/data

if [ x"$OPTIONS_PATH" = x"" ]; then
    OPTIONS_PATH="/tmp/data/options.txt"
fi

CURRENT_TIME=$(head -1 $OPTIONS_PATH) \
    tarantool /opt/tarantool/app.lua
