makefile_path := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

CC ?= gcc
CFLAGS ?= -g -O0 -Wall -Wextra -pedantic -std=gnu99
FC ?= gfortran
FCFLAGS ?= -g -O0 -Wall -Wextra -pedantic

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

argparse.o: $(makefile_path)/src/argparse.c
	$(CC) $(CFLAGS) -I$(makefile_path)/src -o $@ -c $< -fPIC

iri-2016.x: iri_2016.o argparse.o iri_c_interface.o
	$(FC) -o $@ $^ -L$(makefile_path) -liri2016 -lm -fPIC -Wl,-rpath $(makefile_path)

test.x: $(makefile_path)/test/test_iri_c_interface.f90 iri_c_interface.o
	$(FC) $(FCFLAGS) -o $@ $^ -L$(makefile_path) -liri2016 -fPIC -Wl,-rpath $(makefile_path)

compare_logs.x: $(makefile_path)/test/compare_logs.c
	$(CC) $(CFLAGS) -o $@ $^ -lm

check: all test.x compare_logs.x
	cp test.x run
	cd run && ./test.x
	bash test/test.bash

clean:
	rm -f iri-2016.x
	rm -f libiri2016.so
	rm -f *.o *.mod
	rm -f test.x
