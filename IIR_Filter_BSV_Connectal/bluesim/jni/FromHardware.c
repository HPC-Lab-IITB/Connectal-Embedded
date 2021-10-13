#include "GeneratedTypes.h"

int FromHardware_hardware_output ( struct PortalInternal *p, const int32_t v )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_FromHardware_hardware_output, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_FromHardware_hardware_output, "FromHardware_hardware_output")) return 1;
    p->transport->write(p, &temp_working_addr, (v & 0xffffffffL));
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_FromHardware_hardware_output << 16) | 2, -1);
    return 0;
};

FromHardwareCb FromHardwareProxyReq = {
    portal_disconnect,
    FromHardware_hardware_output,
};
FromHardwareCb *pFromHardwareProxyReq = &FromHardwareProxyReq;

const uint32_t FromHardware_reqinfo = 0x10008;
const char * FromHardware_methodSignatures()
{
    return "{\"hardware_output\": [\"long\"]}";
}

int FromHardware_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    FromHardwareData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_FromHardware_hardware_output: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.hardware_output.v = (int32_t)(((tmp)&0xfffffffful));
        ((FromHardwareCb *)p->cb)->hardware_output(p, tempdata.hardware_output.v);
      } break;
    default:
        PORTAL_PRINTF("FromHardware_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("FromHardware_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
