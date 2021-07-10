/* 
 * While interfacing Software and Hardware (this need to send data to Hardware from Software and need to wait for it’s response from Hardware),
 * implement this stalling mechanism using Semaphores (sem_ wait and sem_post).
 * Semaphores are very useful in process synchronization and multithreading.
 * Sem_wait locks the semaphores.
 * Sem_post release (or) signal a Semaphore.
 * In the main description in C++ the functions used to interact with BSV are initialized, input is taken and passed to Hardware, waits for output
 * from Hardware .
 */

#include <errno.h>
#include <stdio.h>
#include "FromHardware.h"
#include "IntoHardware.h"
#include "GeneratedTypes.h"

static IntoHardwareProxy *intoHardware = 0;
static sem_t sem_heard2;

class FromHardware : public FromHardwareWrapper
{
public:
    virtual void hardware_output(uint16_t v) {
        printf("inverse of the matrix in decimal format is: %d\n", v);
	sem_post(&sem_heard2);
    }
    FromHardware(unsigned int id) : FromHardwareWrapper(id) {}
};

static void input_into_hardware(int v)
{
    printf("[%s:%d] %d\n", __FUNCTION__, __LINE__, v);
    intoHardware->hardware_input(v);
    sem_wait(&sem_heard2);
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
    printf("TEST TYPE: SEM\n");
    //intoHardware->setLeds(9);
    return 0;
}
