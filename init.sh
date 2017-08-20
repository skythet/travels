#!/bin/bash

mkdir -p /tmp/data
unzip /tmp/data/data.zip -d /tmp/data

tarantool /opt/tarantool/app.lua
