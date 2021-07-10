/* 
 * The modules called from C++ and rules will be executed whenever the task is executed.
 * FIFO is used to store the input values.
 * Input to this say(v) module is 16-bit, which will be considered as a 4*4 matrix for which the inverse has to be computed.
 * Function “func(v,4)” in which the inverse of the matrix is computed using the Gauss-Jordan method, for which output is of 32 bits - first 16 
 * bits correspond to the input matrix after row operations , next 16 bits correspond to the identity matrix after row operations which will be
 * inverse of the input matrix if inverse exists.
 * After all the row operations, if the input matrix after row operations becomes an identity matrix then we say that the inverse of the matrix
 * exists else it does not exist.
 * If the inverse exists then write the converse of the matrix into the FIFO else write 0 into the FIFO.
*/
import FIFO::*;
import Vector::*;

interface FromHardware;
    method Action hardware_output(Bit#(16) v);
endinterface

interface IntoHardware;
   method Action hardware_input(Bit#(16) v);
endinterface

interface MI;
   interface IntoHardware in;
endinterface

module mkMI#(FromHardware out)(MI);
    FIFO#(Bit#(16)) fifoQueue <- mkSizedFIFO(8);
   
    rule hardware_output;
        fifoQueue.deq;
        out.hardware_output(fifoQueue.first);
    endrule

   interface IntoHardware in;
      
      function Bit#(32) func ( Bit#(16) mat, Integer n) ;
              Bit#(32) out;
	      Bit#(16) inv = 16'b1000010000100001 ;
	      for (Integer i = 0 ; i < n-1 ; i = i+1) begin
	      	 for(Integer j = i+1 ; j < n ; j = j+1) begin
		 	if ( mat[(n*n)-1-(i*n)-i]==mat[(n*n)-1-(j*n)-i] ) begin
		 		for(Integer k = 0 ; k < n ; k = k+1) begin
		 			mat[(n*n)-1-(j*n)-k]=mat[(n*n)-1-(j*n)-k] ^ mat[(n*n)-1-(i*n)-k];
		 			inv[(n*n)-1-(j*n)-k]=inv[(n*n)-1-(j*n)-k] ^ inv[(n*n)-1-(i*n)-k];
		 		end
		 	end
		 end
	      end
	     for (Integer i = n-1 ; i > 0 ; i = i-1) begin
	      	 for(Integer j = i-1 ; j > -1 ; j = j-1) begin
		 	if ( mat[(n*n)-1-(i*n)-i]==mat[(n*n)-1-(j*n)-i] ) begin
		 		for(Integer k = n-1 ; k > -1 ; k = k-1) begin
		 			mat[(n*n)-1-(j*n)-k]=(mat[(n*n)-1-(j*n)-k] ^ mat[(n*n)-1-(i*n)-k]);
		 			inv[(n*n)-1-(j*n)-k]=(inv[(n*n)-1-(j*n)-k] ^ inv[(n*n)-1-(i*n)-k]);
		 		end
		 	end
		 end
	      end
	      out = {mat,inv};
	      return out;
      endfunction
    
      method Action hardware_input(Bit#(16) v);
         Bit#(32) a = func(v,4);
         $display("Input in binary format is %b \n",v);
         if (a[31:16] == 16'b1000010000100001) begin
	 	fifoQueue.enq(a[15:0]);
	 	$display("***********INVERSE OF THE MATRIX EXISTS***********");
	 	$display("Input matrix after row operations is %b \n", a[31:16]);
	 	$display("Inverse of the given matrix is %b \n", a[15:0]);
	 end
	 else begin
	 	fifoQueue.enq(16'b0);
	 	$display("***********INVERSE OF THE MATRIX DONOT EXIST***********");
	 end
      endmethod
      
   endinterface
endmodule
