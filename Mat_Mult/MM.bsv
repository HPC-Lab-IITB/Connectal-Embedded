// Takes multiple input, processes the data and returns multiple output

import FIFO::*;
import Vector::*;

typedef 2 Mat_Size;
// typedef (Mat_Size*Mat_Size) num;
// typedef Mat_Size*Mat_Size*2 no_of_elem_in_matrix1;
Integer n = valueOf(Mat_Size);
int n_b = fromInteger(n);

typedef Int#(32) Data_Type;
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

interface MM;
   interface IntoHardware in;
endinterface

module mkMM#(FromHardware out)(MM) provisos (Mul#(Mat_Size,Mat_Size,num), Mul#(num,2,num1));
	// provisos (Bits #(Data_Type, wt), Literal#(Int#(32)));
	// provisos(Literal#(t#(Reg#(Int#(32)))));
	// provisos(Literal#(Reg#(Int#(32))));
     
    // Integer no_of_elem_in_matrix = n*n;
    // Integer no_of_elem_in_matrix1 = n*n * 2;
    Integer no_of_elem_FIFO = (n*n*2*ordinaryNumber)/64;
    Integer no_of_elem_FIFO1 = (n*n*ordinaryNumber)/64;
    FIFO#(Bit#(64)) inputQueue <- mkSizedFIFO(no_of_elem_FIFO);
    FIFO#(Bit#(64)) outputQueue <- mkSizedFIFO(no_of_elem_FIFO1);

    Reg#(State) state <- mkReg(IDLE);
    Reg#(Bool) done <- mkReg(False);
    Reg#(int) counter <- mkReg(0);
    Reg#(int) count <- mkReg(0);
    
    Reg#(Int#(32)) number_of_inputs <- mkReg(fromInteger(64/ordinaryNumber));
    // Int#(32) num = n_b*n_b*2;
    // Int#(32) num1 = n_b*n_b;
    // Integer number_of_inputs_integer = 64/ordinaryNumber;
    Reg#(Bool) start <- mkReg(False);
    
    /*Vector #(Mat_Size*Mat_Size*2, Reg #(Data_Type)) vec1 <- replicateM (mkRegU);
    Vector #(Mat_Size*Mat_Size, Reg #(Data_Type)) vec2 <- replicateM (mkRegU);*/
    
    Vector #(num1, Reg #(Data_Type)) vec1 <- replicateM (mkRegU); // ------------ WORKING
    Vector #(num, Reg #(Data_Type)) vec2 <- replicateM (mkRegU);  
    
    /*Reg#(Data_Type) vec1[(n*n*2)]; // ------------ WORKING
    for (Integer i=0; i<(n*n*2); i=i+1)
	vec1[i] <- mkRegU;
    Reg#(Data_Type) vec2[n*n];
    for (Integer i=0; i<n*n; i=i+1)
	vec2[i] <- mkRegU;*/
	
      /*Reg#( Vector#(num1,Data_Type) ) vec1 <- mkReg( replicate(0) ) ;
      Reg#( Vector#(num,Data_Type) ) vec2 <- mkReg( replicate(0) ) ;*/
	
     /*Reg#(vec1[(n*n*2),Data_Type]);
    	vec1 <- mkReg( replicate(OK) );
    	
     Reg#(vec2[(n*n),Data_Type]);
	vec2 <- mkReg( replicate(OK) );*/
     
     rule stateIdle ( state == IDLE && start == True); //default state
    	$display("State: IDLE");
    	if (count<fromInteger(no_of_elem_FIFO)) begin
    		inputQueue.deq;
    		Bit#(64) tmp = unpack(inputQueue.first);
    		for (int j=0; j<fromInteger(64/ordinaryNumber); j=j+1) begin
    			vec1[j] <= unpack(tmp[64*count+fromInteger(ordinaryNumber)*j : 64*count+(fromInteger(ordinaryNumber)*(j+1))-1]);
    		end
    	end
    	else begin
    		state <= PROCESS;
    		start <= False;
    	end
    	count <= count + 1;
     endrule
     
     rule statePROCESS (state == PROCESS);
     	$display("State: PROCESS");
     	if(done == False) begin
     		// Data_Type v_tmp[n*n];
     		// Vector#(num, Data_Type) v_tmp = vec2;
     		// Vector#(n*n, Data_Type);
     		let v_tmp = vec2;
     		for(int i=0; i<n_b; i=i+1) begin
	     		for(int j=0; j<n_b; j=j+1) begin
	     			for(int k=0; k<n_b; k=k+1) begin
	     				vec2[(n_b*i)+j] <= vec2[n_b*i+j] + (vec1[(n_b*i)+k] * vec1[(n_b*n_b)+(n_b*k)+j]);
	     				// v_tmp[(n_b*i)+j] = v_tmp[n_b*i+j] + (vec1[(n_b*i)+k] * vec1[(n_b*n_b)+(n_b*k)+j]);
	     			end
	     		end
	     	end
	     	// vec2 <= v_tmp;
	     	done <= True;
	end
     	
     	if(counter < fromInteger(no_of_elem_FIFO1)) begin
     		Bit#(64) temp = 64'b0;
     		for(int i=0; i<fromInteger(64/ordinaryNumber); i=i+1) begin
     			temp[((i+1)*fromInteger(ordinaryNumber))-1:i*fromInteger(ordinaryNumber)] = pack(vec2[n_b*counter+i]);
     		end
     		outputQueue.enq(temp);
     		// outputQueue.enq(pack(vec2[counter*number_of_inputs:(counter+1)*number_of_inputs-1]));
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

