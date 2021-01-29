#include <stdio.h>
#include <stdlib.h>

extern void reduce_contrast(unsigned char *inputFileArray, unsigned int rfactor);

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
        return 0;
    }

    rfactor = atoi(argv[2]);
    if (rfactor < 1 || rfactor > 127)
    {
        printf("Wrong rfactor\n");
        return 0;
    }

    inputFile = fopen(argv[1], "rb");
    if (inputFile == NULL)
    {
        printf("Cannot open the file %s \n", argv[1]);
    }
    else
    {
        outputFile = fopen("out.bmp", "wb");
        fseek(inputFile, 0, SEEK_END);
        fileSize = ftell(inputFile);
        fseek(inputFile, 0, SEEK_SET);

        inputFileArray = malloc(fileSize);
        fread(inputFileArray, 1, fileSize, inputFile);

        reduce_contrast(inputFileArray, rfactor);

        fwrite(inputFileArray, 1, fileSize, outputFile);
        fclose(outputFile);
        fclose(inputFile);
    }
    return 0;
}


