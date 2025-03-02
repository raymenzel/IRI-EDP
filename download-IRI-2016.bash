#!/bin/bash

# Create a run directory.
mkdir -p run

# Download the IRI model and put the data files in the run directory.
mkdir -p IRI-2016
cd IRI-2016
wget https://irimodel.org/IRI-2016/00_iri.tar
tar xvf 00_iri.tar
mv *.dat ../run

# Path the irifun.for source file to prevent a buffer overflow
# when reading the ig_rz,dat file at runtime.
sed -i -e s/aig\(806\),arz\(806\)/aig\(900\),arz\(900\)/g irifun.for
sed -i -e s/ionoindx\(806\),indrz\(806\)/ionoindx\(900\),indrz\(900\)/g irifun.for

# Get the extra files and put them in the run directory.
cd ../run
wget https://irimodel.org/indices/ig_rz.dat
wget https://irimodel.org/indices/apf107.dat
wget https://irimodel.org/COMMON_FILES/00_ccir-ursi.tar
tar xvf 00_ccir-ursi.tar
