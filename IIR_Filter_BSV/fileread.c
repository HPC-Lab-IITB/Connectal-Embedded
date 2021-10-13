#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int32_t fileread(int32_t linenum){
FILE *in_file;
    int32_t number1, i=0;
    // char* line=NULL;
    // size_t len=0;

    in_file = fopen("input101.txt", "r");

    if (in_file == NULL)
    {
        printf("Can't open file for reading.\n");
    }
    else
    {
    	while(i<linenum){
    	// getline(&line, &len, in_file);
    	// number1 = atoi(line);
        fscanf(in_file, "%d", &number1);
        // printf("num is %d\n", atoi(line));
        i++;
        }
    }
    fclose(in_file);
    // return atoi(line);
    return number1;
}

void filewrite(int32_t value){
FILE *in_file;
    int32_t number1, i=0;

    in_file = fopen("filter_output.txt", "a+");

    fprintf(in_file, "%d\n", value);
    
    fclose(in_file);
   // return number1;
}

void fileclear(){
FILE *in_file;

    in_file = fopen("filter_output.txt", "w");
    fclose(in_file);
}
/*int main()
{
    printf("%d",fileread(4));
    printf("%d",tapread(4));
    return 0;
}*/
