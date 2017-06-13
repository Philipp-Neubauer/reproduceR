#!/bin/bash

set -ex

#docker build -t docker.dragonfly.co.nz/auckland_bivalves .

docker run --rm  -v $PWD/..:/work -w /work/report \
  docker.dragonfly.co.nz/auckland_bivalves:v2 ./build.sh
