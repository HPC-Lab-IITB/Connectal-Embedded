#include "GeneratedTypes.h"
#ifndef _INTOHARDWARE_H_
#define _INTOHARDWARE_H_
#include "portal.h"

class IntoHardwareProxy : public Portal {
    IntoHardwareCb *cb;
public:
    IntoHardwareProxy(int id, int tile = DEFAULT_TILE, IntoHardwareCb *cbarg = &IntoHardwareProxyReq, int bufsize = IntoHardware_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    IntoHardwareProxy(int id, PortalTransportFunctions *transport, void *param, IntoHardwareCb *cbarg = &IntoHardwareProxyReq, int bufsize = IntoHardware_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    IntoHardwareProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, IntoHardware_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&IntoHardwareProxyReq) {};
    int hardware_input ( const int32_t v ) { return cb->hardware_input (&pint, v); };
};

extern IntoHardwareCb IntoHardware_cbTable;
class IntoHardwareWrapper : public Portal {
public:
    IntoHardwareWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = IntoHardware_handleMessage, int bufsize = IntoHardware_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&IntoHardware_cbTable, this, poller) {
    };
    IntoHardwareWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = IntoHardware_handleMessage, int bufsize = IntoHardware_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&IntoHardware_cbTable, transport, param, this, poller) {
    };
    IntoHardwareWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, IntoHardware_reqinfo, IntoHardware_handleMessage, (void *)&IntoHardware_cbTable, this, poller) {
    };
    IntoHardwareWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, IntoHardware_reqinfo, IntoHardware_handleMessage, (void *)&IntoHardware_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("IntoHardwareWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void hardware_input ( const int32_t v ) = 0;
};
#endif // _INTOHARDWARE_H_
