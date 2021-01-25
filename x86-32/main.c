#include <stdio.h>
#include <stdlib.h>

extern void *func(unsigned char *inputFileArray, int rfactor);

int main(int argc, char *argv[])
{
    unsigned int rfactor;
    int i = 0;
    long fileSize;

    FILE *outputFile, *inputFile;
    unsigned char *inputFileArray, *outputFileArray;

    if (argc <= 2)
    {
        printf("Too few arguments!\n");
    }
    else
    {
        inputFile = fopen(argv[1], "r+");
        if (inputFile == NULL)
        {
            printf("Cannot open the file %s \n", argv[1]);
        }
        else
        {
            outputFile = fopen("out.bmp", "w");
            fseek(inputFile, 0, SEEK_END);
            fileSize = ftell(inputFile);
            fseek(inputFile, 0, SEEK_SET);

            inputFileArray = malloc(fileSize);
            fread(inputFileArray, 1, fileSize, inputFile);

            rfactor = atoi(argv[2]);

            /*func(inputFileArray, rfactor);*/

            fwrite(inputFileArray, 1, fileSize, outputFile);
            fclose(outputFile);
            fclose(inputFile);
        }
    }

    return 0;
}
