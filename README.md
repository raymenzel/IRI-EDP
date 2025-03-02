# IRI-EDP
Capture and generate electron density profiles using the IRI model.

### How to get this source code
First, clone the repository using git:

```
$ git clone https://github.com/raymenzel/IRI-EDP.git
$ cd IRI-EDP
```

### How to install

##### Docker
A docker image can be built by:

```
$ docker build -t iri-edp:latest .
```

After building the image, you can enter the container environment by running:

```
$ docker run iri-edp:latest
```

##### Linux
This application requires the following dependencies:
- bash
- wget
- tar
- gcc
- gfortran
- gnuplot

A script `download-IRI-2016.bash` is included that will download the IRI 2016
model and the data needed to run it.  After running that script, the application
can be built using make from the base of the repository:

```
$ bash download-IRI-2016.bash
$ make
```

This will create an executable `iri-2016.x` in the current directory.

### How to run the application.
A run directory was set up when the `download-IRI-2016.bash` script was run.
Copy the created `iri-2016.x` executable into the run directory:

```
$ cp iri-2016.x run
```
Next, go into the run directory and run the exectuable:

```
$ cd run
$ ./iri-2016.x
```
