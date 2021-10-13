package FromHardware;

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
} Hardware_output_Message deriving (Bits);

// exposed wrapper portal interface
interface FromHardwareInputPipes;
    interface PipeOut#(Hardware_output_Message) hardware_output_PipeOut;

endinterface
typedef PipePortal#(1, 0, SlaveDataBusWidth) FromHardwarePortalInput;
interface FromHardwareInput;
    interface FromHardwarePortalInput portalIfc;
    interface FromHardwareInputPipes pipes;
endinterface
interface FromHardwareWrapperPortal;
    interface FromHardwarePortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface FromHardwareWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(FromHardwareInputPipes,FromHardware);
   module mkConnection#(FromHardwareInputPipes pipes, FromHardware ifc)(Empty);

    rule handle_hardware_output_request;
        let request <- toGet(pipes.hardware_output_PipeOut).get();
        ifc.hardware_output(request.v);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkFromHardwareInput(FromHardwareInput);
    Vector#(1, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,Hardware_output_Message) hardware_output_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = hardware_output_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Hardware_output_Message)));
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
    interface FromHardwareInputPipes pipes;
        interface hardware_output_PipeOut = hardware_output_requestAdapter.out;
    endinterface
endmodule

module mkFromHardwareWrapperPortal#(FromHardware ifc)(FromHardwareWrapperPortal);
    let dut <- mkFromHardwareInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface FromHardwareWrapperMemPortalPipes;
    interface FromHardwareInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkFromHardwareWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(FromHardwareWrapperMemPortalPipes);

  let dut <- mkFromHardwareInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface FromHardwareInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkFromHardwareWrapper#(idType id, FromHardware ifc)(FromHardwareWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkFromHardwareWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 1, SlaveDataBusWidth) FromHardwarePortalOutput;
interface FromHardwareOutput;
    interface FromHardwarePortalOutput portalIfc;
    interface Iirfilter::FromHardware ifc;
endinterface
interface FromHardwareProxy;
    interface StdPortal portalIfc;
    interface Iirfilter::FromHardware ifc;
endinterface

interface FromHardwareOutputPipeMethods;
    interface PipeIn#(Hardware_output_Message) hardware_output;

endinterface

interface FromHardwareOutputPipes;
    interface FromHardwareOutputPipeMethods methods;
    interface FromHardwarePortalOutput portalIfc;
endinterface

function Bit#(16) getFromHardwareMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Hardware_output_Message)));
    endcase
endfunction

(* synthesize *)
module mkFromHardwareOutputPipes(FromHardwareOutputPipes);
    Vector#(1, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,Hardware_output_Message) hardware_output_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = hardware_output_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface FromHardwareOutputPipeMethods methods;
    interface hardware_output = hardware_output_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getFromHardwareMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkFromHardwareOutput(FromHardwareOutput);
    let indicationPipes <- mkFromHardwareOutputPipes;
    interface Iirfilter::FromHardware ifc;

    method Action hardware_output(Int#(32) v);
        indicationPipes.methods.hardware_output.enq(Hardware_output_Message {v: v});
        //$display("indicationMethod 'hardware_output' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(FromHardwareOutput);
   function Bit#(16) portalMessageSize(FromHardwareOutput p, Bit#(16) methodNumber);
      return getFromHardwareMessageSize(methodNumber);
   endfunction
endinstance


interface FromHardwareInverse;
    method ActionValue#(Hardware_output_Message) hardware_output;

endinterface

interface FromHardwareInverter;
    interface Iirfilter::FromHardware ifc;
    interface FromHardwareInverse inverseIfc;
endinterface

instance Connectable#(FromHardwareInverse, FromHardwareOutputPipeMethods);
   module mkConnection#(FromHardwareInverse in, FromHardwareOutputPipeMethods out)(Empty);
    mkConnection(in.hardware_output, out.hardware_output);

   endmodule
endinstance

(* synthesize *)
module mkFromHardwareInverter(FromHardwareInverter);
    FIFOF#(Hardware_output_Message) fifo_hardware_output <- mkFIFOF();

    interface Iirfilter::FromHardware ifc;

    method Action hardware_output(Int#(32) v);
        fifo_hardware_output.enq(Hardware_output_Message {v: v});
    endmethod
    endinterface
    interface FromHardwareInverse inverseIfc;

    method ActionValue#(Hardware_output_Message) hardware_output;
        fifo_hardware_output.deq;
        return fifo_hardware_output.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkFromHardwareInverterV(FromHardwareInverter);
    PutInverter#(Hardware_output_Message) inv_hardware_output <- mkPutInverter();

    interface Iirfilter::FromHardware ifc;

    method Action hardware_output(Int#(32) v);
        inv_hardware_output.mod.put(Hardware_output_Message {v: v});
    endmethod
    endinterface
    interface FromHardwareInverse inverseIfc;

    method ActionValue#(Hardware_output_Message) hardware_output;
        let v <- inv_hardware_output.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkFromHardwareProxySynth#(Bit#(SlaveDataBusWidth) id)(FromHardwareProxy);
  let dut <- mkFromHardwareOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface Iirfilter::FromHardware ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkFromHardwareProxy#(idType id)(FromHardwareProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkFromHardwareProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: FromHardware
