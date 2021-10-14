
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include "FromHardware.h"
#include "IntoHardware.h"
#include "FromHardware1.h"
#include "IntoHardware1.h"
#include "GeneratedTypes.h"
#include <iostream>
#include <thread>
using namespace std;	

static IntoHardwareProxy *intoHardware = 0;
static IntoHardware1Proxy *intoHardware1 = 0;
static sem_t sem_in1, sem_in2;
static sem_t sem_out1, sem_out2;

// Type of each element in the Vector
typedef int8_t data_type;

// Length of the Vector
const int vec_len = 32;

// const int a = vec_len*(int)(sizeof(data_type)*8)/64;
const int a = 1;
int count1 = 0;
int count2 = 0;

uint64_t out1, out2;

class FromHardware : public FromHardwareWrapper
{
public:
    virtual void hardware_output(uint64_t v) {
    	out1 = v;
        printf("*****Output received successfully from hardware*****%ld\n", out1);
        if(count1 == a-1)
		sem_post(&sem_out1);
	count1+=1;
    }
    virtual void input_sent_to_hardware() {
    	// clock_t CPU_time_1 = clock();
        printf("*****Input sent to hardware successfully*****\n");
        sem_post(&sem_in1);
    }
    FromHardware(unsigned int id) : FromHardwareWrapper(id) {}
};

class FromHardware1 : public FromHardware1Wrapper
{
public:
    virtual void hardware_output(uint64_t v) {
    	out2 = v;
        printf("*****Output received successfully from hardware-2*****%ld\n", out2);
        if(count2 == a-1)
		sem_post(&sem_out2);
	count2+=1;
    }
    virtual void input_sent_to_hardware() {
    	// clock_t CPU_time_1 = clock();
        printf("*****Input sent to hardware-2 successfully*****\n");
        sem_post(&sem_in2);
    }
    FromHardware1(unsigned int id) : FromHardware1Wrapper(id) {}
};

static void input_into_hardware(uint64_t v)
{
    // printf("[%s:%d] %ld\n", __FUNCTION__, __LINE__, v);
    intoHardware->hardware_input(v);
    sem_wait(&sem_in1);
}

static void input_into_hardware1(uint64_t v)
{
    // printf("[%s:%d] %ld\n", __FUNCTION__, __LINE__, v);
    intoHardware1->hardware_input(v);
    sem_wait(&sem_in2);
}

static void output_from_hardware()
{
    // printf("[%s:%d] \n", __FUNCTION__, __LINE__);
    intoHardware->implement_mat_mul();
    sem_wait(&sem_out1);
}

static void output_from_hardware1()
{
    // printf("[%s:%d] \n", __FUNCTION__, __LINE__);
    intoHardware1->implement_mat_mul();
    sem_wait(&sem_out2);
}

int main(int argc, const char **argv)
{
    long actualFrequency = 0;
    long requestedFrequency = 1e9 / MainClockPeriod;

    FromHardware fromHardware(IfcNames_FromHardwareH2S);
    FromHardware1 fromHardware1(IfcNames_FromHardware1H2S);
    intoHardware = new IntoHardwareProxy(IfcNames_IntoHardwareS2H);
    intoHardware1 = new IntoHardware1Proxy(IfcNames_IntoHardware1S2H);

    int status = setClockFrequency(0, requestedFrequency, &actualFrequency);
    fprintf(stderr, "Requested main clock frequency %5.2f, actual clock frequency %5.2f MHz status=%d errno=%d\n",
	    (double)requestedFrequency * 1.0e-6,
	    (double)actualFrequency * 1.0e-6,
	    status, (status != 0) ? errno : 0);

    data_type v1[vec_len] = {10,2,3,-4,20,-2,50,14,10,2,3,-4,20,-2,50,14,10,2,3,-4,20,-2,50,14,10,2,3,-4,20,-2,50,14};
    data_type v2[vec_len] = {-100,-2,-120,50,80,13,12,11,-100,-2,-120,50,80,13,12,11,-100,-2,-120,50,80,13,12,11,-100,-2,-120,50,80,13,12,11};
    data_type v3[2*vec_len], v4[2*vec_len];
    int64_t t1,t2,len =(int)(64/(sizeof(data_type)*8)), p;
    int64_t tmp;
    for(int i=0; i<vec_len/2; i+=len){
    	for(int j=0; j<len; j++){
    		v3[2*i+j] = v1[i+j];
    		v4[2*i+j] = v1[i+j+vec_len/2];
    	}
    	for(int j=0; j<len; j++){
    		v3[2*i+j+len] = v2[i+j];
    		v4[2*i+j+len] = v2[i+j+vec_len/2];
    	}
    }
    
    for(int i=0; i<(int)((vec_len*(sizeof(data_type)*8))/64); i++){
    	t1=0; p=1;t2=0;
    	for(int j=0; j<len; j++){
    		tmp = (v3[len*i+j]>=0) ? (int64_t)v3[len*i+j] : (int64_t)(pow(2,int(sizeof(data_type)*8))+v3[len*i+j]) ;
    		t1 += (int64_t)(p*tmp);
    		tmp = (v4[len*i+j]>=0) ? (int64_t)v4[len*i+j] : (int64_t)(pow(2,int(sizeof(data_type)*8))+v4[len*i+j]) ;
    		t2 += (int64_t)(p*tmp);
    		p*=(int)(pow(2,(int)(sizeof(data_type)*8)));
    	}
    	thread th1(input_into_hardware, t1);
    	thread th2(input_into_hardware1, t2);
    	th1.join();
	th2.join();
    }
    
    thread th3(output_from_hardware);
    thread th4(output_from_hardware1);
    
    th3.join();
    th4.join();
    
    printf("FINAL OUTPUT = %ld\n", out1+out2);
    printf("TEST TYPE: SEM\n");
    return 0;
}

