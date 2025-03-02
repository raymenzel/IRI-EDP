makefile_path := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

CC = gcc
CFLAGS = -g -O0 -Wall -Wextra -pedantic -std=c99
FC = gfortran
FCFLAGS = -g -O0 -Wall -Wextra -pedantic

IRI_SOURCES = $(makefile_path)/IRI-2016/irisub.for \
              $(makefile_path)/IRI-2016/irifun.for \
              $(makefile_path)/IRI-2016/iritec.for \
              $(makefile_path)/IRI-2016/iridreg.for \
              $(makefile_path)/IRI-2016/igrf.for \
              $(makefile_path)/IRI-2016/cira.for \
              $(makefile_path)/IRI-2016/iriflip.for

all: libiri2016.so iri-2016.x

libiri2016.so: $(IRI_SOURCES)
	$(FC) -shared $(FCFLAGS) $(IRI_SOURCES) -o $@ -fPIC

iri_2016.o: $(makefile_path)/src/iri_2016.c
	$(CC) $(CFLAGS) -o $@ -c $< -fPIC

iri_c_interface.o: $(makefile_path)/src/iri_c_interface.f90
	$(FC) $(FCFLAGS) -o $@ -c $< -fPIC

iri-2016.x: iri_2016.o iri_c_interface.o
	$(FC) -o $@ $^ -L$(makefile_path) -liri2016 -fPIC -Wl,-rpath $(makefile_path)

test: test/test_iri_c_interface.f90
	$(FC) $(FCFLAGS) -o $@ $^ -L$(makefile_path) -liri2016 -fPIC -Wl,-rpath $(makefile_path)

clean:
	rm -f iri-2016.x
	rm -f libiri2016.so
	rm -f *.o *.mod
