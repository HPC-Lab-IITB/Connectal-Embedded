// Takes multiple input, processes the data and returns multiple output

import FIFO::*;
import Vector::*;

typedef enum { IDLE, PROCESS, STOP } State deriving(Bits,Eq);

interface FromHardware;
    method Action hardware_output(Bit#(64) v);
    method Action input_sent_to_hardware;
endinterface

interface IntoHardware;
   method Action hardware_input(Bit#(64) v);
   method Action implement_mat_mul();
endinterface

interface Minp;
   interface IntoHardware in;
endinterface

module mkMinp#(FromHardware out)(Minp);
    FIFO#(Bit#(64)) inputQueue <- mkSizedFIFO(8);
    FIFO#(Bit#(64)) outputQueue <- mkSizedFIFO(8);
    Reg #(Bool) rg_busy <- mkReg( False ) ;
    Reg#(State) state <- mkReg(IDLE);
    Reg#(int) counter <- mkReg(0);
    Reg#(int) count <- mkReg(0);
    Reg#(int) number_of_inputs <- mkReg(2);
    Integer number_of_inputs_integer = 2;
    Reg#(Bool) start <- mkReg(False);
    Reg#(Bit#(64)) vec1[2];
    for (Integer i=0; i<number_of_inputs_integer; i=i+1)
	vec1[i] <- mkRegU;
    
    
     rule stateIdle ( state == IDLE && start == True); //default state
    	$display("State: IDLE");
    	if (count<number_of_inputs) begin
    		inputQueue.deq;
    		vec1[count] <= inputQueue.first;
    		state <= IDLE;
    	end
    	else begin
    		state <= PROCESS;
    		start <= False;
    	end
    	count <= count + 1;
     endrule
     
     rule statePROCESS (state == PROCESS);
     	$display("State: PROCESS");
     	if(counter < number_of_inputs) begin
     		outputQueue.enq(vec1[counter]*10);
		state <= PROCESS;
	end
	else
		state <= STOP;
	counter <= counter + 1;
     endrule
     rule stateSTOP ( state == STOP );
     	$display("State: STOP");
	outputQueue.deq;
	out.hardware_output(outputQueue.first);
     endrule

   interface IntoHardware in;
   
      method Action hardware_input(Bit#(64) v);
	 $display("*****Input received by hardware*****");
	 inputQueue.enq(v);
	 out.input_sent_to_hardware();
      endmethod
      
      method Action implement_mat_mul();
	start <= True;
	state <= IDLE;
      endmethod
      	
   endinterface
endmodule
