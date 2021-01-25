#include <stdio.h>
#include <stdlib.h>

extern void *func(unsigned char *inputImageArray, int rfactor);

int main(int argc, char *argv[])
{
    unsigned int rfactor;
    int i = 0;
    long fileSize;

    FILE *outputImage, *inputImage;
    unsigned char *inputImageArray, *outputImageArray;

    if (argc <= 2)
    {
        printf("Too few arguments!\n");
    }
    else
    {
        inputImage = fopen(argv[1], "r+");
        if (inputImage == NULL)
        {
            printf("Cannot open the file %s \n", argv[1]);
        }
        else
        {
            outputImage = fopen("out.bmp", "w");
            fseek(inputImage, 0, SEEK_END);
            fileSize = ftell(inputImage);
            fseek(inputImage, 0, SEEK_SET);

            inputImageArray = malloc(fileSize);
            fread(inputImageArray, 1, fileSize, inputImage);

            rfactor = atoi(argv[2]);

            /*func(inputImageArray, rfactor);*/

            fwrite(inputImageArray, 1, fileSize, outputImage);
            fclose(outputImage);
            fclose(inputImage);
        }
    }

    return 0;
}
