# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Install dependencies.
RUN apt-get update && apt-get install -y build-essential
RUN apt-get update && apt-get install -y wget
RUN apt-get update && apt-get install -y git
RUN apt-get update && apt-get install -y gfortran
RUN apt-get update && apt-get install -y gnuplot
RUN cd / && git clone https://github.com/raymenzel/IRI-EDP.git
RUN cd /IRI-EDP && git checkout dev
RUN cd /IRI-EDP && bash download-IRI-2016.bash
RUN cd /IRI-EDP && make
RUN cd /IRI-EDP && mkdir -p output

CMD ["bash"]
