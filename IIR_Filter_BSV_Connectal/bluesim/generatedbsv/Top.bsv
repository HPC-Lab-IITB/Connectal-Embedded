
import ConnectalConfig::*;
import Vector::*;
import BuildVector::*;
import Portal::*;
import CnocPortal::*;
import Connectable::*;
import HostInterface::*;
import ConnectalMemTypes::*;
`include "ConnectalProjectConfig.bsv"
import IfcNames::*;
import `PinTypeInclude::*;
import FromHardware::*;
import Iirfilter::*;
import IntoHardware::*;

typedef 1 NumberOfRequests;
typedef 1 NumberOfIndications;

`ifndef IMPORT_HOSTIF
(* synthesize *)
`endif
module mkCnocTop
`ifdef IMPORT_HOSTIF
       #(HostInterface host)
`else
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
       #(Clock derivedClockIn, Reset derivedResetIn)
`else
// otherwise no params
`endif
`endif
       (CnocTop#(NumberOfRequests,NumberOfIndications,PhysAddrWidth,DataBusWidth,`PinType,NumberOfMasters));
   Clock defaultClock <- exposeCurrentClock();
   Reset defaultReset <- exposeCurrentReset();
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
   HostInterface host = (interface HostInterface;
                           interface Clock derivedClock = derivedClockIn;
                           interface Reset derivedReset = derivedResetIn;
                         endinterface);
`endif
   FromHardwareOutput lFromHardwareOutput <- mkFromHardwareOutput;
   IntoHardwareInput lIntoHardwareInput <- mkIntoHardwareInput;

   let lIirfilter <- mkIirfilter(lFromHardwareOutput.ifc);

   mkConnection(lIntoHardwareInput.pipes, lIirfilter.in);

   let lFromHardwareOutputNoc <- mkPortalMsgIndication(extend(pack(IfcNames_FromHardwareH2S)), lFromHardwareOutput.portalIfc.indications, lFromHardwareOutput.portalIfc.messageSize);
   let lIntoHardwareInputNoc <- mkPortalMsgRequest(extend(pack(IfcNames_IntoHardwareS2H)), lIntoHardwareInput.portalIfc.requests);
   Vector#(NumWriteClients,MemWriteClient#(DataBusWidth)) nullWriters = replicate(null_mem_write_client());
   Vector#(NumReadClients,MemReadClient#(DataBusWidth)) nullReaders = replicate(null_mem_read_client());

   interface requests = vec(lIntoHardwareInputNoc);
   interface indications = vec(lFromHardwareOutputNoc);
   interface readers = take(nullReaders);
   interface writers = take(nullWriters);
`ifdef TOP_SOURCES_PORTAL_CLOCK
   interface portalClockSource = None;
`endif


endmodule : mkCnocTop
export mkCnocTop;
export NumberOfRequests;
export NumberOfIndications;
export `PinTypeInclude::*;
