#!/bin/bash -e

test_directory=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
cp $test_directory/../iri-2016.x $test_directory/../run
cd $test_directory/../run

# Run the executable.
./iri-2016.x 37.8 284.6 2019 3 1 12 -z 80 -Z 600 -dz 10
if [ "$?" -ne "0" ]; then
  echo "iri-2016.x failed"
  exit 1
fi

# Make sure it created the plot.
if [ ! -f "2019-03-01-12-UTC-EDP.png" ]; then
  echo "iri-2016.x failed to produce the EDP plot."
  exit 1
fi

# Compare the log file to the expected one.
../compare_logs.x iri_2016.log $test_directory/iri_2016.log
if [ "$?" -ne "0" ]; then
  echo "iri-2016.x did not produce the expected data."
  exit 1
fi
