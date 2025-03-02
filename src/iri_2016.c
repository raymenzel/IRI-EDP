#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* Forward function declaration for iri_sub wrapper.*/
void iri_main(
    int * options, /*IRI options.*/
    int coordinate_system, /*0 = geographic, 1 = geomagnetic.*/
    float latitude_north, /*Location latitude in degrees north.*/
    float longitude_east, /*Location longitude in degrees east.*/
    int year, /*Year of interest.*/
    int date, /*Month and day of interest in format MMDD.*/
    float hour, /*Hour of interest in UTC.*/
    float height_lower, /*Lowest height [km] for the vertical profile.*/
    float height_upper, /*Highest height [km] for the vertical profile.*/
    float dheight, /*Step size [km] for the profile height grid.*/
    float * output, /*Ouput data from IRI.*/
    float * additional_output /*Additional output data from IRI.*/
);


/*Coordinate options.*/
enum coordinates
{
    GEOGRAPHIC = 0,
    GEOMAGNETIC = 1
};


/*Main driver program.*/
int main(int argc, char ** argv)
{

    /*Set defaults.*/
    int coordinate_system = GEOGRAPHIC;
    float latitude_north = 37.8; /* [Degrees north].*/
    float longitude_east = 360. - 75.4; /* [Degrees east].*/
    int year = 2021; /* Year in format YYYY.*/
    int date = 303; /* Date in format MMDD.*/
    float hour = 11.;
    float height_lower = 80.; /* Lowest height [km].*/
    float height_upper = 600.; /* Highest height [km].*/
    float dheight = 10.; /* Height grid spacing [km].*/
    float output[20000];
    float additional_output[100];
    int options[50]; /*IRI options.*/
    int i;
    for (i=0; i<50; ++i)
    {
        options[i] = 1; /*Turn all options on.*/
    }

    /*Turn off the options that the readme tells me to.*/
    int off_switch_indices[13] = {
        4, 5, 6, 21, 23, 28, 29, 30, 33, 35, 39, 40, 47
    };
    for (i=0; i<13; ++i)
    {
        options[off_switch_indices[i] - 1] = 0;
    }

     /*Call the fortran routines.*/
    iri_main(options, coordinate_system, latitude_north,
             longitude_east, year, date, hour, height_lower,
             height_upper, dheight, output, additional_output);

    /*Decode the output.*/
    float electron_density[1000]; /*Electron number density [m-3].*/
    for (i=0; i<1000; ++i)
    {
        int j;
        for (j=0; j<20; ++j)
        {
            electron_density[i] = output[i*20];
        }
    }

    /*Calculate the vertical grid.*/
    int num_heights = (height_upper - height_lower)/dheight + 1;
    float heights[1000]; /*Vertical profile.*/
    for (i=0; i<num_heights; ++i)
    {
        heights[i] = height_lower + i*dheight;
    }

    /*Make the electron density plot.*/
    fprintf(stdout, "Height[km]\t\tElectron density [m-3]\n");
    fprintf(stdout, "----------\t\t----------------------\n");
    for (i=0; i<num_heights; ++i)
    {
        fprintf(stdout, "%e\t\t%e\n", heights[i], electron_density[i]);
    }


    return EXIT_SUCCESS;
}
