#!/bin/bash

mkdir -p /srv/data
unzip /tmp/data/data.zip -d /srv/data

tarantool /opt/tarantool/app.lua
