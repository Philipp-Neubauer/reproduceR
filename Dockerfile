FROM rocker/r-ver:3.4.0
LABEL maintainer="philipp"
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update \
 && apt-get install -y pandoc texinfo texlive\
	pandoc-citeproc
RUN ["install2.r", "-r 'https://cloud.r-project.org'", "knitr", "magrittr", "stringi", "stringr", "evaluate"]
RUN apt-get install -y biber
WORKDIR /work/
COPY ["this_report.Rnw", "this_report.Rnw"]
