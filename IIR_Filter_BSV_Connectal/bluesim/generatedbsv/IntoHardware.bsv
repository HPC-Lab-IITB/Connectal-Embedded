package IntoHardware;

import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Connectable::*;
import Clocks::*;
import FloatingPoint::*;
import Adapter::*;
import Leds::*;
import Vector::*;
import SpecialFIFOs::*;
import ConnectalConfig::*;
import ConnectalMemory::*;
import Portal::*;
import CtrlMux::*;
import ConnectalMemTypes::*;
import Pipe::*;
import HostInterface::*;
import LinkerLib::*;
import Iirfilter::*;
import FIFO::*;
import FIFOF::*;
import Vector::*;
import ClientServer::*;
import GetPut::*;
import definedTypes::*;




typedef struct {
    Int#(32) v;
} Hardware_input_Message deriving (Bits);

// exposed wrapper portal interface
interface IntoHardwareInputPipes;
    interface PipeOut#(Hardware_input_Message) hardware_input_PipeOut;

endinterface
typedef PipePortal#(1, 0, SlaveDataBusWidth) IntoHardwarePortalInput;
interface IntoHardwareInput;
    interface IntoHardwarePortalInput portalIfc;
    interface IntoHardwareInputPipes pipes;
endinterface
interface IntoHardwareWrapperPortal;
    interface IntoHardwarePortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface IntoHardwareWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(IntoHardwareInputPipes,IntoHardware);
   module mkConnection#(IntoHardwareInputPipes pipes, IntoHardware ifc)(Empty);

    rule handle_hardware_input_request;
        let request <- toGet(pipes.hardware_input_PipeOut).get();
        ifc.hardware_input(request.v);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkIntoHardwareInput(IntoHardwareInput);
    Vector#(1, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,Hardware_input_Message) hardware_input_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = hardware_input_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Hardware_input_Message)));
            endcase
        endmethod
        endinterface
        interface Vector requests = requestPipeIn;
        interface Vector indications = nil;
        interface PortalInterrupt intr;
           method Bool status();
              return False;
           endmethod
           method Bit#(dataWidth) channel();
              return -1;
           endmethod
        endinterface
    endinterface
    interface IntoHardwareInputPipes pipes;
        interface hardware_input_PipeOut = hardware_input_requestAdapter.out;
    endinterface
endmodule

module mkIntoHardwareWrapperPortal#(IntoHardware ifc)(IntoHardwareWrapperPortal);
    let dut <- mkIntoHardwareInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface IntoHardwareWrapperMemPortalPipes;
    interface IntoHardwareInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkIntoHardwareWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(IntoHardwareWrapperMemPortalPipes);

  let dut <- mkIntoHardwareInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface IntoHardwareInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkIntoHardwareWrapper#(idType id, IntoHardware ifc)(IntoHardwareWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkIntoHardwareWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 1, SlaveDataBusWidth) IntoHardwarePortalOutput;
interface IntoHardwareOutput;
    interface IntoHardwarePortalOutput portalIfc;
    interface Iirfilter::IntoHardware ifc;
endinterface
interface IntoHardwareProxy;
    interface StdPortal portalIfc;
    interface Iirfilter::IntoHardware ifc;
endinterface

interface IntoHardwareOutputPipeMethods;
    interface PipeIn#(Hardware_input_Message) hardware_input;

endinterface

interface IntoHardwareOutputPipes;
    interface IntoHardwareOutputPipeMethods methods;
    interface IntoHardwarePortalOutput portalIfc;
endinterface

function Bit#(16) getIntoHardwareMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Hardware_input_Message)));
    endcase
endfunction

(* synthesize *)
module mkIntoHardwareOutputPipes(IntoHardwareOutputPipes);
    Vector#(1, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,Hardware_input_Message) hardware_input_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = hardware_input_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface IntoHardwareOutputPipeMethods methods;
    interface hardware_input = hardware_input_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getIntoHardwareMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkIntoHardwareOutput(IntoHardwareOutput);
    let indicationPipes <- mkIntoHardwareOutputPipes;
    interface Iirfilter::IntoHardware ifc;

    method Action hardware_input(Int#(32) v);
        indicationPipes.methods.hardware_input.enq(Hardware_input_Message {v: v});
        //$display("indicationMethod 'hardware_input' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(IntoHardwareOutput);
   function Bit#(16) portalMessageSize(IntoHardwareOutput p, Bit#(16) methodNumber);
      return getIntoHardwareMessageSize(methodNumber);
   endfunction
endinstance


interface IntoHardwareInverse;
    method ActionValue#(Hardware_input_Message) hardware_input;

endinterface

interface IntoHardwareInverter;
    interface Iirfilter::IntoHardware ifc;
    interface IntoHardwareInverse inverseIfc;
endinterface

instance Connectable#(IntoHardwareInverse, IntoHardwareOutputPipeMethods);
   module mkConnection#(IntoHardwareInverse in, IntoHardwareOutputPipeMethods out)(Empty);
    mkConnection(in.hardware_input, out.hardware_input);

   endmodule
endinstance

(* synthesize *)
module mkIntoHardwareInverter(IntoHardwareInverter);
    FIFOF#(Hardware_input_Message) fifo_hardware_input <- mkFIFOF();

    interface Iirfilter::IntoHardware ifc;

    method Action hardware_input(Int#(32) v);
        fifo_hardware_input.enq(Hardware_input_Message {v: v});
    endmethod
    endinterface
    interface IntoHardwareInverse inverseIfc;

    method ActionValue#(Hardware_input_Message) hardware_input;
        fifo_hardware_input.deq;
        return fifo_hardware_input.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkIntoHardwareInverterV(IntoHardwareInverter);
    PutInverter#(Hardware_input_Message) inv_hardware_input <- mkPutInverter();

    interface Iirfilter::IntoHardware ifc;

    method Action hardware_input(Int#(32) v);
        inv_hardware_input.mod.put(Hardware_input_Message {v: v});
    endmethod
    endinterface
    interface IntoHardwareInverse inverseIfc;

    method ActionValue#(Hardware_input_Message) hardware_input;
        let v <- inv_hardware_input.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkIntoHardwareProxySynth#(Bit#(SlaveDataBusWidth) id)(IntoHardwareProxy);
  let dut <- mkIntoHardwareOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface Iirfilter::IntoHardware ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkIntoHardwareProxy#(idType id)(IntoHardwareProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkIntoHardwareProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: IntoHardware
