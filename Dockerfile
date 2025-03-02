# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Install dependencies.
RUN apt-get update && apt-get install git gfortran gnuplot
RUN git clone https://github.com/raymenzel/IRI-EDP.git
RUN cd IRI-EDP
RUN bash download-IRI-2016.bash
RUN make

CMD ["bash"]
