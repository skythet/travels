#!/bin/bash

DATA_PATH=$1

docker run --rm \
    -d --memory=4g \
    -e OPTIONS_PATH="/srv/data/options.txt" \
    -v "$DATA_PATH":/srv/data \
    -v $(pwd):/opt/tarantool \
    --name travels \
    -p 8888:80 travels