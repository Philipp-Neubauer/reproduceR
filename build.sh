#!/bin/bash

set -ex

Rscript -e "knitr::knit('this_report.Rnw')"

# Gorbachev only
cp this_report.pdf /output/
