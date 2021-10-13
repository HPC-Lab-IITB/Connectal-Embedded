
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "FromHardware.h"
#include "IntoHardware.h"
#include "GeneratedTypes.h"
#include <stdint.h>

static IntoHardwareProxy *intoHardware = 0;
static sem_t sem_in;

int32_t fileread(int32_t linenum){
FILE *in_file;
    int32_t number1 = 0, i = 0;
    char* line=NULL;
    size_t len=0;

    in_file = fopen("input101.txt", "r");

    if (in_file == NULL)
    {
        printf("Can't open file for reading.\n");
        char cwd[500];
        if (getcwd(cwd, sizeof(cwd)) != NULL)
        	printf("Current working dir: %s\n", cwd);
    }
    else
    {
    	while(i<linenum){
    	if(getline(&line, &len, in_file)==0)
    		return -1;
    	number1 = atoi(line);
        //if(fscanf(in_file, "%d", &number1)==0)
        //	return -1;
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

    in_file = fopen("filter_output.txt", "a+");

    fprintf(in_file, "%d\n", value);
    
    fclose(in_file);
}

void fileclear(){
FILE *in_file;

    in_file = fopen("filter_output.txt", "w");
    fclose(in_file);
}

int count = 0;

class FromHardware : public FromHardwareWrapper
{
public:
    virtual void hardware_output(int32_t v) {
        // printf("*****Output received successfully from hardware*****%d\n", v);
	sem_post(&sem_in);
	if(count<1) fileclear();
	else filewrite(v);
	count+=1;
    }
    FromHardware(signed int id) : FromHardwareWrapper(id) {}
};

static void input_into_hardware(int32_t v)
{
    // printf("[%s:%d] %ld\n", __FUNCTION__, __LINE__, v);
    intoHardware->hardware_input(v);
    sem_wait(&sem_in);
}

int main(int argc, const char **argv)
{
    long actualFrequency = 0;
    long requestedFrequency = 1e9 / MainClockPeriod;

    FromHardware fromHardware(IfcNames_FromHardwareH2S);
    intoHardware = new IntoHardwareProxy(IfcNames_IntoHardwareS2H);

    int status = setClockFrequency(0, requestedFrequency, &actualFrequency);
    fprintf(stderr, "Requested main clock frequency %5.2f, actual clock frequency %5.2f MHz status=%d errno=%d\n",
	    (double)requestedFrequency * 1.0e-6,
	    (double)actualFrequency * 1.0e-6,
	    status, (status != 0) ? errno : 0);

    for(int i=0; i<1502; i++){
    	input_into_hardware(fileread(i));
    }

    printf("TEST TYPE: SEM\n");
    return 0;
}

