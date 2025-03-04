#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "argparse.h"


/* Forward function declaration for iri_sub wrapper.*/
void iri_main(
    int * options, /*IRI options.*/
    int coordinate_system, /*0 = geographic, 1 = geomagnetic.*/
    float latitude_north, /*Location latitude in degrees north.*/
    float longitude_east, /*Location longitude in degrees east.*/
    int year, /*Year of interest.*/
    int date, /*Month and day of interest in format MMDD.*/
    float hour, /*Hour of interest in UTC.*/
    float altitude_lower, /*Lowest altitude [km] for the vertical profile.*/
    float altitude_upper, /*Highest altitude [km] for the vertical profile.*/
    float daltitude, /*Step size [km] for the profile altitude grid.*/
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
    /*Parse command line arguments.*/
    char * description = "Calculates electron density profiles using IRI 2016.";
    int one = 1;
    Parser_t parser = create_parser(argc, argv, description);
    add_argument(&parser, "latitude", NULL, "Latitude [Degrees north].", NULL);
    add_argument(&parser, "longitude", NULL, "Longitude [Degrees east].", NULL);
    add_argument(&parser, "year", NULL, "Year of the desired profile.", NULL);
    add_argument(&parser, "month", NULL, "Month of tht desired profile..", NULL);
    add_argument(&parser, "day", NULL, "Day of the desired profile.", NULL);
    add_argument(&parser, "hour", NULL, "Hour [UTC] of the desired profile.", NULL);
    add_argument(&parser, "-z", NULL, "Minimum altitude [km] (Default: 80).", &one);
    add_argument(&parser, "-Z", NULL, "Maximum altitude [km] (Default: 1000).", &one);
    add_argument(&parser, "-dz", NULL, "Altitude grid spacing [km] (Default 20).", &one);
    add_argument(&parser, "-p", NULL, "Plot plasma frequency instead of number density.", NULL);
    parse_args(parser);

    /*Set arguments to IRI.*/
    char buffer[512];
    get_argument(parser, "latitude", buffer);
    float latitude_north = atof(buffer);

    get_argument(parser, "longitude", buffer);
    float longitude_east = atof(buffer);

    get_argument(parser, "year", buffer);
    int year = atoi(buffer);

    get_argument(parser, "month", buffer);
    int month = atoi(buffer);

    get_argument(parser, "day", buffer);
    int day = atoi(buffer);
    int date = month*100 + day; /* Date in format MMDD.*/

    get_argument(parser, "hour", buffer);
    float hour = atof(buffer);
    if (hour < 0. || hour > 24.)
    {
        fprintf(stderr, "Error: the input hour %f must be >= 0 and <= 24.\n", hour);
        return EXIT_FAILURE;
    }
    hour += 25.; /*IRI assumes that it is local time unless this is >= 25.*/

    float altitude_lower = get_argument(parser, "-z", buffer) ? atof(buffer) : 80.;
    float altitude_upper = get_argument(parser, "-Z", buffer) ? atof(buffer) : 600.;
    float daltitude = get_argument(parser, "-dz", buffer) ? atof(buffer) : 20.;
    int output_type = get_argument(parser, "-p", buffer) ? 1 : 0;

    int coordinate_system = GEOGRAPHIC;
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
             longitude_east, year, date, hour, altitude_lower,
             altitude_upper, daltitude, output, additional_output);

    /*Construct a string for the input time.*/
    struct tm input_time = {
        .tm_sec = 0,
        .tm_min = 0,
        .tm_hour = (int)(hour - 25.),
        .tm_mday = date % 100,
        .tm_mon = (date - (date % 100))/100 - 1,
        .tm_year = year - 1900,
    };
    char date_string[100];
    strftime(date_string, 100, "%m/%d/%Y at %H:00 UTC", &input_time);
    char file_tag[100];
    strftime(file_tag, 100, "%Y-%m-%d-%H-UTC", &input_time);

    /*Create a pipe to gnuplot.*/
    FILE * pipe = popen("gnuplot -persistent", "w");
    if (pipe == NULL)
    {
        fprintf(stderr, "Failed to open the pipe to gnuplot.\n");
        perror("popen");
        return EXIT_FAILURE;
    }

    /*Initialize the plot.*/
    fprintf(pipe, "set terminal png lw 3 \n");
    fprintf(pipe, "set output '%s-EDP.png' \n", file_tag);
    fprintf(pipe, "set title \"EDP for %s\\nLocation: %4.1f N, %4.1f E\" \n",
            date_string, latitude_north, longitude_east);
    if (output_type)
    {
        fprintf(pipe, "set xlabel \"Plasma Frequency [MHz]\" \n");
    }
    {
        fprintf(pipe, "set xlabel \"Electron Number Density [cm-3]\" \n");
    }
    fprintf(pipe, "set ylabel \"Altitude [km]\" \n");
    fprintf(pipe, "set key noautotitle \n");
    fprintf(pipe, "set key noautotitle \n");
    fprintf(pipe, "plot '-' with lines \n");

    /*Conversion factor from sqrt(electron_density [m-3]) to MHz.*/
    float to_MHz = 8.978359105589245e-06; /* [ m1.5 MHz ] */

    /*Decode the output and pass it to gnuplot.*/
    int num_altitudes = (altitude_upper - altitude_lower)/daltitude + 1;
    for (i=0; i<num_altitudes; ++i)
    {
        float altitude = altitude_lower + i*daltitude;
        float electron_density;
        if (output_type)
        {
            electron_density = sqrtf(output[i*20])*to_MHz; /*[MHz].*/
        }
        else
        {
            electron_density = output[i*20]*1.e-6; /*[cm-3].*/
        }
        fprintf(pipe, "%e %e\n", electron_density, altitude);
    }
    fprintf(pipe, "exit \n");

    /*Close the pipe.*/
    if (pclose(pipe) == -1)
    {
        fprintf(stderr, "Failed to close the pipe to gnuplot.\n");
        perror("pclose");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
