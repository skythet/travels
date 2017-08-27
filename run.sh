#!/bin/bash

DATA_PATH=$1

docker run --rm \
    -d --memory=4g\
    -v "$DATA_PATH":/srv/data \
    -v $(pwd):/opt/tarantool \
    --name hlcup \
    -p 8888:80 hlcup 