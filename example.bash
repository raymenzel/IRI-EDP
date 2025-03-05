#!/bin/bash -x

# Build the executable.
make

# Copy the executable into the run directory.
cp iri-2016.x run

# Run the executable at the desired location and times.
cd run

latitude="37.8" # Degrees north.
longitude="-75.4" # Degrees easth (= 75.4 W)
year="2021"
month="3" # March
day="3"
hour="11" # UTC

echo "Running IRI at ($latitude N, $longitude E) @ $year/$month/$day $hour:00:00 UTC"
./iri-2016.x $latitude $longitude $year $month $day $hour


day="4"
hour="23" # UTC
echo "Running IRI at ($latitude N, $longitude E) @ $year/$month/$day $hour:00:00 UTC"
./iri-2016.x $latitude $longitude $year $month $day $hour
