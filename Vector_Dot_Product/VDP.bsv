// Computes Vector Dat Product of 2 vectors.

import FIFO::*;
import Vector::*;
import Utils :: *;

typedef 16 Vec_len;

Integer n = valueOf(Vec_len);
int n_b = fromInteger(n);

typedef Int#(8) Data_Type;
typedef SizeOf#(Data_Type) Size_Data;
Integer size_Data_b = valueOf(Size_Data);

typedef enum { IDLE, PROCESS, STOP } State deriving(Bits,Eq);

interface FromHardware;
    method Action hardware_output(Bit#(64) v);
    method Action input_sent_to_hardware;
endinterface

interface IntoHardware;
   method Action hardware_input(Bit#(64) v);
   method Action implement_mat_mul();
endinterface

interface VDP;
   interface IntoHardware in;
endinterface

module mkVDP#(FromHardware out)(VDP) provisos (Mul#(Vec_len,2,num1), Div#(64,Size_Data,num2));

    Integer n1 = n*2;
    
    FIFO#(Bit#(64)) inputQueue1 <- mkSizedFIFO(n1);
    FIFO#(Bit#(64)) inputQueue2 <- mkSizedFIFO(n1);

    Reg#(State) state <- mkReg(IDLE);
    Reg#(int) count <- mkReg(0);
    Reg#(int) count1 <- mkReg(0);
    Reg#(int) count2 <- mkReg(0);
    Reg#(Int#(32)) number_of_inputs <- mkReg(fromInteger(64/size_Data_b));
    Reg#(Bool) start <- mkReg(False);
    Reg#(Int#(64)) result <- mkReg(0);
    
    rule statePROCESS (state == PROCESS);
     	$display("%d: State: PROCESS",cur_cycle);
     	if(count!=fromInteger(64/size_Data_b)) begin
     		Bit#(64) vec1 = (inputQueue1.first);
     		Bit#(64) vec2 = (inputQueue2.first);
     		Data_Type v_temp1 = unpack((vec1>>(fromInteger(size_Data_b)*count))[size_Data_b-1:0]);
     		Data_Type v_temp2 = unpack((vec2>>(fromInteger(size_Data_b)*count))[size_Data_b-1:0]);
     		
     		result <= result + signExtend(v_temp1) * signExtend(v_temp2);
     		count <= count + 1;
     		count2 <= count2 + 1;
     	end
     	else begin
     		inputQueue1.deq;
     		inputQueue2.deq;
     		count <= 0;
     	end 
     endrule
     
     rule stateSTOP ( state == STOP && count2==n_b );
     	$display("%d: State: STOP",cur_cycle);
	Bit#(64) temp = pack(result);
	out.hardware_output(temp);
	count2 <= count2 + 1;
     endrule

   interface IntoHardware in;
   
      method Action hardware_input(Bit#(64) v);
	 $display("%d : *****Input received by hardware*****",cur_cycle);
    	if(count1%2!=0) begin
    		state <= PROCESS;
    		inputQueue2.enq(v);
    	end
    	else begin
    		inputQueue1.enq(v);
    	end
    	count1 <= count1+1;
	out.input_sent_to_hardware();
      endmethod
      
      method Action implement_mat_mul();
	state <= STOP;
      endmethod
      	
   endinterface
endmodule

