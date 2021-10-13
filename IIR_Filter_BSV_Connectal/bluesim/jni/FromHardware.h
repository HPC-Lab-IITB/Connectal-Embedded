#include "GeneratedTypes.h"
#ifndef _FROMHARDWARE_H_
#define _FROMHARDWARE_H_
#include "portal.h"

class FromHardwareProxy : public Portal {
    FromHardwareCb *cb;
public:
    FromHardwareProxy(int id, int tile = DEFAULT_TILE, FromHardwareCb *cbarg = &FromHardwareProxyReq, int bufsize = FromHardware_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    FromHardwareProxy(int id, PortalTransportFunctions *transport, void *param, FromHardwareCb *cbarg = &FromHardwareProxyReq, int bufsize = FromHardware_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    FromHardwareProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, FromHardware_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&FromHardwareProxyReq) {};
    int hardware_output ( const int32_t v ) { return cb->hardware_output (&pint, v); };
};

extern FromHardwareCb FromHardware_cbTable;
class FromHardwareWrapper : public Portal {
public:
    FromHardwareWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = FromHardware_handleMessage, int bufsize = FromHardware_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&FromHardware_cbTable, this, poller) {
    };
    FromHardwareWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = FromHardware_handleMessage, int bufsize = FromHardware_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&FromHardware_cbTable, transport, param, this, poller) {
    };
    FromHardwareWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, FromHardware_reqinfo, FromHardware_handleMessage, (void *)&FromHardware_cbTable, this, poller) {
    };
    FromHardwareWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, FromHardware_reqinfo, FromHardware_handleMessage, (void *)&FromHardware_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("FromHardwareWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void hardware_output ( const int32_t v ) = 0;
};
#endif // _FROMHARDWARE_H_
