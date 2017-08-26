#!/bin/bash

DATA_PATH=$1

docker run --rm \
    -d -e TZ=Europe/Moscow \
    -v "$DATA_PATH":/srv/data \
    -v $(pwd):/opt/tarantool \
    --name hlcup \
    -p 8888:80 hlcup 