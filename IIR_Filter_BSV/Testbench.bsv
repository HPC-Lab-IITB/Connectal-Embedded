
package Testbench;

import FIFO :: *;
import Vector :: *;
import ClientServer :: *;
import GetPut :: *;

// ================================================================
// Project imports

import definedTypes      :: *;
// import Iir_filter1_IFC :: *;
import iir_filter3 :: *;
import "BDPI" fileread = function ActionValue#(Int#(32)) bsv_fread(Int#(32) linenum); //importing fileread function implemented in C into BSV
import "BDPI" filewrite = function Action bsv_fwrite(Int#(32) value); // importing filewrite function implemented in C into BSV
import "BDPI" fileclear = function Action bsv_fclear(); // importing fileclear function implemented in C into BSV

// ================================================================
// Testbench module

(* synthesize *)
module mkTestbench (Empty);
   
   Reg #(Int#(32)) count <- mkReg (0);
   Reg#(Int#(32)) dout <- mkReg(0);
   Reg#(Bool) signal <- mkReg(False);
   
   Iir_filter1_IFC filter <- mk_iir_filter3;
   
   // (* mutually_exclusive = "empty, empty1" *)
   
   rule r1(count<1502);
   	let x <- bsv_fread(count); // read the line count from the file
   	filter.compute_IFC.request.put(truncate(x)); // send input input into the design
   	// $display("Input is %d %d", x, truncate(pack(x)));
   	count <= count + 1;
   endrule
// (!signal)
    rule empty;
	let z <- filter.compute_IFC.response.get (); // get output from the design file into the testbench
	dout <= truncate(z);
        // $display ("Output %d", dout);
        //$display ("%d", dout);
        if(count == 3) bsv_fclear;
        if(count<1502) bsv_fwrite(dout); // write the value into the file
        else $finish();
        // $display ("count %d", count);
    endrule
    
    /*rule empty1;
    	$finish();
    endrule**/
   
endmodule: mkTestbench

// ================================================================

endpackage
