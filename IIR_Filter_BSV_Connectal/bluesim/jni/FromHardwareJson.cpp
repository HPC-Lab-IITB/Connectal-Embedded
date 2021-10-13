#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int FromHardwareJson_hardware_output ( struct PortalInternal *p, const int32_t v )
{
    Json::Value request;
    request.append(Json::Value("hardware_output"));
    request.append((Json::Int64)v);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_FromHardware_hardware_output);
    return 0;
};

FromHardwareCb FromHardwareJsonProxyReq = {
    portal_disconnect,
    FromHardwareJson_hardware_output,
};
FromHardwareCb *pFromHardwareJsonProxyReq = &FromHardwareJsonProxyReq;
const char * FromHardwareJson_methodSignatures()
{
    return "{\"hardware_output\": [\"long\"]}";
}

int FromHardwareJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    FromHardwareData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_FromHardware_hardware_output: {
        ((FromHardwareCb *)p->cb)->hardware_output(p, tempdata.hardware_output.v);
      } break;
    default:
        PORTAL_PRINTF("FromHardwareJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("FromHardwareJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
