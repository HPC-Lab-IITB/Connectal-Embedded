#include "GeneratedTypes.h"

int IntoHardware_hardware_input ( struct PortalInternal *p, const int32_t v )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_IntoHardware_hardware_input, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_IntoHardware_hardware_input, "IntoHardware_hardware_input")) return 1;
    p->transport->write(p, &temp_working_addr, (v & 0xffffffffL));
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_IntoHardware_hardware_input << 16) | 2, -1);
    return 0;
};

IntoHardwareCb IntoHardwareProxyReq = {
    portal_disconnect,
    IntoHardware_hardware_input,
};
IntoHardwareCb *pIntoHardwareProxyReq = &IntoHardwareProxyReq;

const uint32_t IntoHardware_reqinfo = 0x10008;
const char * IntoHardware_methodSignatures()
{
    return "{\"hardware_input\": [\"long\"]}";
}

int IntoHardware_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    IntoHardwareData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_IntoHardware_hardware_input: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.hardware_input.v = (int32_t)(((tmp)&0xfffffffful));
        ((IntoHardwareCb *)p->cb)->hardware_input(p, tempdata.hardware_input.v);
      } break;
    default:
        PORTAL_PRINTF("IntoHardware_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("IntoHardware_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
