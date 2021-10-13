
package iir_filter3;

// ----------------------------------------------------------------
// From the BSV library

import FIFO :: *;
import FIFOF :: *;
import Vector :: *;
import ClientServer :: *;
import GetPut :: *;

// ----------------------------------------------------------------
// Imports for this project

import definedTypes :: *;
import "BDPI" fileread = function ActionValue#(Int#(32)) bsv_fread(Int#(32) linenum);

typedef Int#(Width_x) Type_in;
typedef Int#(Width_y) Type_out;

// ----------------------------------------------------------------

interface Iir_filter1_IFC;
   interface Server#(Type_in,Type_out) compute_IFC;
endinterface

(* synthesize *)
module mk_iir_filter3 (Iir_filter1_IFC);
   
   FIFO #(Int#(Width_x)) fifo_in <- mkSizedFIFO(5);
   FIFO #(Int#(Width_y)) fifo_out <- mkSizedFIFO(5);
   
   T_f_f_taps  f_f_taps;
   for (Int#(32) i=0; i<=fromInteger(n_f_b_taps); i=i+1)
   	if(i==0) f_f_taps[i] = 1;
   	else if(i==1) f_f_taps[i] = 5;
   	else if(i==2) f_f_taps[i] = 7;
   	else if(i==3) f_f_taps[i] = 5;
   	else if(i==4) f_f_taps[i] = 1;
   	else f_f_taps[i] = 0;
   	
   T_f_b_taps  f_b_taps;
   for (Integer i=0; i<=n_f_f_taps; i=i+1)
   	if(i==1) f_b_taps[i] = fromInteger(-607);
   	else if(i==2) f_b_taps[i] = fromInteger(592);
   	else if(i==3) f_b_taps[i] = fromInteger(-270);
   	else if(i==4) f_b_taps[i] = fromInteger(48);
   	else f_b_taps[i] = 0;
   
   Vector#(TAdd#(N_order,1), Reg#(Int#(Width_x))) samples_x <- replicateM(mkReg(0));
    
   Vector#(TAdd#(N_order,1), Reg#(Int#(Width_y))) samples_y <- replicateM(mkReg(0));
   
   Reg#(Int#(TAdd#(TAdd#(Width_x,Tap_width),Log2_N_order))) data_f_f <- mkReg(0);
   
   Reg#(Int#(Width_y)) data_f_b <- mkReg(0);
   
   Reg#(Int#(Width_y)) sig_dout <- mkReg(0);
   
   rule r1;
   		    
   	Int#(32) x = signExtend(f_f_taps[0])*signExtend(samples_x[0]) 
   		    + signExtend(f_f_taps[1])*signExtend(samples_x[1])
   		    + signExtend(f_f_taps[2])*signExtend(samples_x[2])
   		    + signExtend(f_f_taps[3])*signExtend(samples_x[3])
   		    + signExtend(f_f_taps[4])*signExtend(samples_x[4])
   		    + signExtend(f_f_taps[5])*signExtend(samples_x[5])
   		    + signExtend(f_f_taps[6])*signExtend(samples_x[6])
   		    + signExtend(f_f_taps[7])*signExtend(samples_x[7])
   		    + signExtend(f_f_taps[8])*signExtend(samples_x[8]);
   		    
   	Int#(64) y = signExtend(f_b_taps[0])*signExtend(samples_y[0])
   		    + signExtend(f_b_taps[1])*signExtend(samples_y[1])
   		    + signExtend(f_b_taps[2])*signExtend(samples_y[2])
   		    + signExtend(f_b_taps[3])*signExtend(samples_y[3])
   		    + signExtend(f_b_taps[4])*signExtend(samples_y[4])
   		    + signExtend(f_b_taps[5])*signExtend(samples_y[5])
   		    + signExtend(f_b_taps[6])*signExtend(samples_y[6])
   		    + signExtend(f_b_taps[7])*signExtend(samples_y[7])
   		    + signExtend(f_b_taps[8])*signExtend(samples_y[8]);
   	
   	Int#(Width_y) z = signExtend(x) - truncate(y>>n_fraction_bits);
   	
   	fifo_out.enq(z);
   	
   	fifo_in.deq;
   	
   	samples_x[0] <= fifo_in.first;
   	samples_x[1] <= samples_x[0];
   	samples_y[1] <= z;
   	for(int i=2; i<=fromInteger(n_order); i=i+1) begin
   		samples_x[i] <= samples_x[i-1];
   		samples_y[i] <= samples_y[i-1];
   	end
   	
   endrule
   
   interface compute_IFC = toGPServer (fifo_in, fifo_out);
   
endmodule: mk_iir_filter3

// ----------------------------------------------------------------

endpackage: iir_filter3
