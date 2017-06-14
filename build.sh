#!/bin/bash

set -ex

Rscript -e "knitr::knit2pdf('this_report.Rnw')"

# Gorbachev only
cp this_report.pdf /output/
