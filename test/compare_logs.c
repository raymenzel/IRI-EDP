#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define cleanup(log1, log2) { \
    fclose(log1); \
    fclose(log2); \
    return EXIT_FAILURE; \
}

#define raise(code, log1, log2) { \
    if ((code) != 0) \
    { \
        cleanup(log1, log2); \
    } \
}


int get_tokens(char * c, char * token1, char * token2,
               int max_token_length, char separator,
               int skip_space)
{
    int i = 0;
    while (*c != separator)
    {
        if (i >= max_token_length)
        {
            fprintf(stderr, "Error: cannot parse line.\n");
            return 1;
        }
        token1[i] = *c;
        c++;
        i++;
    }
    token1[i] = '\0'; /* Completed token 1.*/
    if (skip_space)
    {
        c++; /* Skip space. */
    }
    i = 0;
    while (*c != '\n')
    {
        if (i >= max_token_length)
        {
            fprintf(stderr, "Error: cannot parse line.\n");
            return 1;
        }
        token2[i] = *c;
        c++;
        i++;
    }
    token2[i] = '\0';
    return 0;
}


int compare_floats(char * token1, char * token2, int line_num)
{
    float value1 = atof(token1);
    float value2 = atof(token2);
    float tolerance = 1.e-5;
    if (fabs(value1 - value2) > tolerance)
    {
        fprintf(stderr, "Error: floating point difference (%e != %e) on line: %d.\n",
                value1, value2, line_num);
        return 1;
    }
    return 0;
}


int main(int argc, char ** argv)
{
    if (argc != 3)
    {
        fprintf(stderr, "Usage: %s log1 log2\n", argv[0]);
        return EXIT_SUCCESS;
    }

    FILE * log1 = fopen(argv[1], "r");
    if (log1 == NULL)
    {
        fprintf(stderr, "Error: could not open log %s.\n", argv[1]);
    }

    FILE * log2 = fopen(argv[2], "r");
    if (log1 == NULL)
    {
        fprintf(stderr, "Error: could not open log %s.\n", argv[1]);
    }

    char line_a[256];
    char line_b[256];
    int num_lines = 0;
    char token_1a[256];
    char token_1b[256];
    char token_2a[256];
    char token_2b[256];
    while(fgets(line_a, 256, log1) != NULL && fgets(line_b, 256, log2) != NULL)
    {
        if (line_a == NULL || line_b == NULL)
        {
            fprintf(stderr, "Error: the log files have different numbers of lines.\n");
            cleanup(log1, log2);
        }

        num_lines++;
        if (num_lines == 9)
        {
            /* This line should be blank.*/
            if (*line_a != '\n' || *line_b != '\n')
            {
                fprintf(stderr, "Error: Line %d should be blank.\n", num_lines);
                cleanup(log1, log2);
            }
        }
        else if (num_lines <= 8)
        {
            /*  Make sure that the inputs that were passed to IRI were the same.*/
            char * character_a = line_a;
            memset(token_1a, 0, sizeof(char)*256);
            memset(token_2a, 0, sizeof(char)*256);
            int code = get_tokens(character_a, token_1a, token_2a, 256, ':', 1);
            raise(code, log1, log2);

            char * character_b = line_b;
            memset(token_1b, 0, sizeof(char)*256);
            memset(token_2b, 0, sizeof(char)*256);
            code = get_tokens(character_b, token_1b, token_2b, 256, ':', 1);
            raise(code, log1, log2);

            if (strcmp(token_1a, token_1b) != 0)
            {
                fprintf(stderr, "Error: token mismatch (%s != %s) on line: %d.\n",
                        token_1a, token_1b, num_lines);
                cleanup(log1, log2);
            }
            code = compare_floats(token_2a, token_2b, num_lines);
            raise(code, log1, log2);
        }
        else
        {
            char * character_a = line_a;
            memset(token_1a, 0, sizeof(char)*256);
            memset(token_2a, 0, sizeof(char)*256);
            int code = get_tokens(character_a, token_1a, token_2a, 256, ',', 0);
            raise(code, log1, log2);

            char * character_b = line_b;
            memset(token_1b, 0, sizeof(char)*256);
            memset(token_2b, 0, sizeof(char)*256);
            code = get_tokens(character_b, token_1b, token_2b, 256, ',', 0);
            raise(code, log1, log2);

            code = compare_floats(token_1a, token_1b, num_lines);
            raise(code, log1, log2);
            code = compare_floats(token_2a, token_2b, num_lines);
            raise(code, log1, log2);
        }
    }

    fclose(log1);
    fclose(log2);
    return EXIT_SUCCESS;
}
