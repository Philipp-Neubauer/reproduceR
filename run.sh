#!/bin/bash
set -ex

ln -sf $(Rscript -e "cat(system.file(\"cli/container_it.R\", package=\"containeRit\"))") /usr/local/bin/containerit

containerit file -f this_report.Rnw

DATE=`date +%Y-%m-%d`
docker build -t docker.dragonfly.co.nz/this_report:$DATE .
docker push docker.dragonfly.co.nz/this_report:$DATE

docker run --net host --rm -v $PWD:/payload -w /payload docker.dragonfly.co.nz/this_report:$DATE ./build.sh
