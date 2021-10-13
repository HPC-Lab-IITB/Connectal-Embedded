/*
 * Generated by Bluespec Compiler (build 26e119fb)
 * 
 * On Sat Oct  2 10:49:54 IST 2021
 * 
 */

/* Generation options: */
#ifndef __mkFromHardwareOutputPipes_h__
#define __mkFromHardwareOutputPipes_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkFromHardwareOutputPipes module */
class MOD_mkFromHardwareOutputPipes : public Module {
 
 /* Clock handles */
 private:
  tClock __clk_handle_0;
 
 /* Clock gate handles */
 public:
  tUInt8 *clk_gate[0];
 
 /* Instantiation parameters */
 public:
 
 /* Module state */
 public:
  MOD_Reg<tUInt32> INST_hardware_output_responseAdapter_bits;
  MOD_Reg<tUInt8> INST_hardware_output_responseAdapter_notEmptyReg;
  MOD_Reg<tUInt8> INST_hardware_output_responseAdapter_shift;
 
 /* Constructor */
 public:
  MOD_mkFromHardwareOutputPipes(tSimStateHdl simHdl, char const *name, Module *parent);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_hardware_output_responseAdapter_notEmptyReg__h198;
  tUInt8 DEF_NOT_hardware_output_responseAdapter_notEmptyReg___d2;
 
 /* Local definitions */
 private:
 
 /* Rules */
 public:
 
 /* Methods */
 public:
  tUInt32 METH_portalIfc_messageSize_size(tUInt32 ARG_portalIfc_messageSize_size_methodNumber);
  tUInt8 METH_RDY_portalIfc_messageSize_size();
  void METH_methods_hardware_output_enq(tUInt32 ARG_methods_hardware_output_enq_v);
  tUInt8 METH_RDY_methods_hardware_output_enq();
  tUInt8 METH_methods_hardware_output_notFull();
  tUInt8 METH_RDY_methods_hardware_output_notFull();
  tUInt32 METH_portalIfc_indications_0_first();
  tUInt8 METH_RDY_portalIfc_indications_0_first();
  void METH_portalIfc_indications_0_deq();
  tUInt8 METH_RDY_portalIfc_indications_0_deq();
  tUInt8 METH_portalIfc_indications_0_notEmpty();
  tUInt8 METH_RDY_portalIfc_indications_0_notEmpty();
  tUInt8 METH_portalIfc_intr_status();
  tUInt8 METH_RDY_portalIfc_intr_status();
  tUInt32 METH_portalIfc_intr_channel();
  tUInt8 METH_RDY_portalIfc_intr_channel();
 
 /* Reset routines */
 public:
  void reset_RST_N(tUInt8 ARG_rst_in);
 
 /* Static handles to reset routines */
 public:
 
 /* Pointers to reset fns in parent module for asserting output resets */
 private:
 
 /* Functions for the parent module to register its reset fns */
 public:
 
 /* Functions to set the elaborated clock id */
 public:
  void set_clk_0(char const *s);
 
 /* State dumping routine */
 public:
  void dump_state(unsigned int indent);
 
 /* VCD dumping routines */
 public:
  unsigned int dump_VCD_defs(unsigned int levels);
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkFromHardwareOutputPipes &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkFromHardwareOutputPipes &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkFromHardwareOutputPipes &backing);
};

#endif /* ifndef __mkFromHardwareOutputPipes_h__ */