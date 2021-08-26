
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "FromHardware.h"
#include "IntoHardware.h"
#include "GeneratedTypes.h"

static IntoHardwareProxy *intoHardware = 0;
static sem_t sem_in;
static sem_t sem_out;

// Type of each element in the Vector
typedef int8_t data_type;

// Length of the Vector
const int vec_len = 16;

// const int a = vec_len*(int)(sizeof(data_type)*8)/64;
const int a = 1;
int count1 = 0;

class FromHardware : public FromHardwareWrapper
{
public:
    virtual void hardware_output(uint64_t v) {
        printf("*****Output received successfully from hardware*****%ld\n", v);
        if(count1 == a-1)
		sem_post(&sem_out);
	count1+=1;
    }
    virtual void input_sent_to_hardware() {
    	// clock_t CPU_time_1 = clock();
        printf("*****Input sent to hardware successfully*****\n");
        sem_post(&sem_in);
    }
    FromHardware(unsigned int id) : FromHardwareWrapper(id) {}
};

static void input_into_hardware(uint64_t v)
{
    // printf("[%s:%d] %ld\n", __FUNCTION__, __LINE__, v);
    intoHardware->hardware_input(v);
    sem_wait(&sem_in);
}

static void output_from_hardware()
{
    // printf("[%s:%d] \n", __FUNCTION__, __LINE__);
    intoHardware->implement_mat_mul();
    sem_wait(&sem_out);
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

    data_type v1[vec_len] = {10,2,3,-4,20,-2,50,14,10,2,3,-4,20,-2,50,14};
    data_type v2[vec_len] = {-100,-2,-120,50,80,13,12,11,-100,-2,-120,50,80,13,12,11};
    data_type v3[2*vec_len];
    int64_t v,len =(int)(64/(sizeof(data_type)*8)), p;
    int64_t tmp;
    for(int i=0; i<vec_len; i+=len){
    	for(int j=0; j<len; j++){
    		v3[2*i+j] = v1[i+j];
    	}
    	for(int j=0; j<len; j++){
    		v3[2*i+j+len] = v2[i+j];
    	}
    }
    
    for(int i=0; i<(int)((2*vec_len*(sizeof(data_type)*8))/64); i++){
    	v=0; p=1;
    	for(int j=0; j<len; j++){
    		tmp = (v3[len*i+j]>=0) ? (int64_t)v3[len*i+j] : (int64_t)(pow(2,int(sizeof(data_type)*8))+v3[len*i+j]) ;
    		v += (int64_t)(p*tmp);
    		p*=(int)(pow(2,(int)(sizeof(data_type)*8)));
    	}
    	input_into_hardware(v);
    }

    output_from_hardware();
    printf("TEST TYPE: SEM\n");
    return 0;
}

