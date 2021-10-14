CONNECTALDIR?=../..
S2H_INTERFACES = IntoHardware:VDP.in IntoHardware1:VDP1.in
H2S_INTERFACES = VDP:FromHardware VDP1:FromHardware1

BSVFILES = VDP.bsv VDP1.bsv
CPPFILES= testVDP.cpp

CONNECTALFLAGS += -D TRACE_PORTAL

include $(CONNECTALDIR)/Makefile.connectal

