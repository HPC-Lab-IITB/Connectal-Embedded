/* Sends multiple input to hardware and recives the processed output over multiple clock cycles
*/

#include <errno.h>
#include <stdio.h>
#include "FromHardware.h"
#include "IntoHardware.h"
#include "GeneratedTypes.h"

static IntoHardwareProxy *intoHardware = 0;
static sem_t sem_in;
static sem_t sem_out;
const int a = 2;
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
        printf("*****Input sent to hardware successfully*****\n");
        sem_post(&sem_in);
    }
    FromHardware(unsigned int id) : FromHardwareWrapper(id) {}
};

static void input_into_hardware(uint64_t v)
{
    printf("[%s:%d] %ld\n", __FUNCTION__, __LINE__, v);
    intoHardware->hardware_input(v);
    sem_wait(&sem_in);
}

static void output_from_hardware()
{
    printf("[%s:%d] \n", __FUNCTION__, __LINE__);
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

    int v = 40046;
    input_into_hardware(v);
    input_into_hardware(40047);
    output_from_hardware();
    printf("TEST TYPE: SEM\n");
    //intoHardware->setLeds(9);
    return 0;
}
