package definedTypes;
	import Vector::*;
// ----------------------------------------------------------------
// Interface definition

	typedef 8 N_fraction_bits;
	Integer n_fraction_bits = valueOf(N_fraction_bits);

	typedef 16 Tap_width;
	Integer tap_width = valueOf(Tap_width);

	typedef 8 N_order;
	Integer n_order = valueOf(N_order);
	
	typedef TLog#(N_order) Log2_N_order;
	Integer log2_N_order = valueOf(Log2_N_order);

	typedef 8 Width_x;
	Integer width_x = valueOf(Width_x);
	
	typedef TAdd#(TMul#(Log2_N_order,2),TAdd#(Width_x,TMul#(Tap_width,2))) Width_y;
	Integer width_y = valueOf(Width_y);
	
	typedef N_order N_f_b_taps;
	Integer n_f_b_taps = valueOf(N_f_b_taps);
	
	typedef TAdd#(N_f_b_taps,1) N_f_f_taps;
	Integer n_f_f_taps = valueOf(N_f_f_taps);
	
	/*typedef TAdd#(width_x,1) Width_x_plus_1;
	Integer width_x_plus_1 = valueOf(Width_x_plus_1);*/
	
	typedef Vector#(TAdd#(N_f_b_taps,1) , Int#(Tap_width)) T_f_f_taps;
	
	typedef Vector#(TAdd#(N_f_f_taps,1), Int#(Tap_width)) T_f_b_taps;
	
	/*typedef Vector#(TAdd#(N_f_b_taps,1) , Reg#(Bit#(Tap_width))) T_f_f_taps;
	
	typedef Vector#(TAdd#(N_f_f_taps,1), Reg#(Bit#(Tap_width))) T_f_b_taps;*/

// ----------------------------------------------------------------

endpackage: definedTypes
