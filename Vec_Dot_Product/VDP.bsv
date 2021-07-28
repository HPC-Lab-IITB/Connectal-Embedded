// Takes multiple input, processes the data and returns multiple output

import FIFO::*;
import Vector::*;

typedef 8 Vec_len;

Integer n = valueOf(Vec_len);
int n_b = fromInteger(n);

typedef Int#(16) Data_Type;
typedef SizeOf#(Data_Type) NumberOfBits;
Integer ordinaryNumber = valueOf(NumberOfBits);

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

module mkVDP#(FromHardware out)(VDP) provisos (Mul#(Vec_len,2,num1));
    Integer no_of_elem_FIFO = (n*2*ordinaryNumber)/64;
    Integer no_of_elem_FIFO1 = (n*ordinaryNumber)/64;
    FIFO#(Bit#(64)) inputQueue <- mkSizedFIFO(no_of_elem_FIFO);
    FIFO#(Bit#(64)) outputQueue <- mkSizedFIFO(no_of_elem_FIFO1);

    Reg#(State) state <- mkReg(IDLE);
    Reg#(Bool) done <- mkReg(False);
    Reg#(int) counter <- mkReg(0);
    Reg#(int) count <- mkReg(0);
    Reg#(Int#(32)) number_of_inputs <- mkReg(fromInteger(64/ordinaryNumber));
    Reg#(Bool) start <- mkReg(False);
    Vector #(num1, Reg #(Data_Type)) vec1 <- replicateM (mkRegU); 
    Reg#(Int#(64)) result <- mkReg(0);
    
    
     rule stateIdle ( state == IDLE && start == True); //default state
    	$display("State: IDLE");
    	if (count<fromInteger(no_of_elem_FIFO)) begin
    		Bit#(64) tmp = unpack(inputQueue.first);
    		inputQueue.deq;
    		for (int j=0; j<fromInteger(64/ordinaryNumber); j=j+1) begin
    			vec1[(count*fromInteger(64/ordinaryNumber))+j] <= unpack(tmp[64*count+(fromInteger(ordinaryNumber)*(j+1))-1 : 64*count+fromInteger(ordinaryNumber)*j]);
    			//$display("%d\n",vec1[j]);
    		end
    	end
    	else begin
    		state <= PROCESS;
    		start <= False;
    	end
    	count <= count + 1;
     endrule
     
     rule check(done && state==PROCESS);
     	$display("*********************");
     	for(int i=0; i<(2*n_b); i=i+1) begin
     		$display("%d %d",i,vec1[i]);
     	end
     	$display("*********************");
     endrule
     
     rule statePROCESS (state == PROCESS);
     	$display("State: PROCESS");
     	if(done == False) begin
     		$display("processing\n");
	     	Int#(64) t = 0;
	     	for(int i=0; i<n_b; i=i+1) begin
	     		t = t + zeroExtend(vec1[i]) * zeroExtend(vec1[n_b+i]);
	     		// $display("%d %d %d %d",t,vec1[i],vec1[n_b+i],vec1[i]*vec1[n_b+i]);
	     	end
	     	result <= t;
	     	done <= True;
	end
		if(done==True) begin
			Bit#(64) temp = pack(result);
			outputQueue.enq(temp);
			state <= STOP;
		end
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

