#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int IntoHardwareJson_hardware_input ( struct PortalInternal *p, const int32_t v )
{
    Json::Value request;
    request.append(Json::Value("hardware_input"));
    request.append((Json::Int64)v);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_IntoHardware_hardware_input);
    return 0;
};

IntoHardwareCb IntoHardwareJsonProxyReq = {
    portal_disconnect,
    IntoHardwareJson_hardware_input,
};
IntoHardwareCb *pIntoHardwareJsonProxyReq = &IntoHardwareJsonProxyReq;
const char * IntoHardwareJson_methodSignatures()
{
    return "{\"hardware_input\": [\"long\"]}";
}

int IntoHardwareJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    IntoHardwareData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_IntoHardware_hardware_input: {
        ((IntoHardwareCb *)p->cb)->hardware_input(p, tempdata.hardware_input.v);
      } break;
    default:
        PORTAL_PRINTF("IntoHardwareJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("IntoHardwareJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
