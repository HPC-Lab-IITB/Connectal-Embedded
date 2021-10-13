

##    run: run the program
##         pass parameters to software via 'make RUN_ARGS= run'
RUN_ARGS?=

export DTOP=/home/likhita/connectal/examples/IIR_Fil/bluesim
CONNECTALDIR=/home/likhita/connectal
BSVPATH = /home/likhita/connectal/examples/IIR_Fil:/home/likhita/connectal/bsv:/home/likhita/connectal/examples/IIR_Fil/bluesim/generatedbsv:/home/likhita/connectal/lib/bsv:/home/likhita/connectal/generated/xilinx:/home/likhita/connectal/generated/altera

BOARD=bluesim
PROJECTDIR=/home/likhita/connectal/examples/IIR_Fil/bluesim
MKTOP=mkXsimTop
OS=ubuntu
TOOLCHAIN?=
DUT=mkxsimtop

export INTERFACES = MemServerRequest MMURequest MemServerIndication MMUIndication XsimMsgRequest XsimMsgIndication IntoHardware FromHardware
BSVFILES = /home/likhita/connectal/examples/IIR_Fil/Iirfilter.bsv /home/likhita/connectal/bsv/ConnectalMemory.bsv /home/likhita/connectal/bsv/XsimIF.bsv /home/likhita/connectal/examples/IIR_Fil/bluesim/generatedbsv/IfcNames.bsv /home/likhita/connectal/bsv/DisplayInd.bsv
XCIFILES = 

BSCFLAGS_PROJECT = 
SIM_CXX_PROJECT = 
CFLAGS_PROJECT = 
CXXFLAGS_PROJECT = 
XELABFLAGS = 
XSIMFLAGS  = -R
AWSFLAGS   = 
TOPBSVFILE = /home/likhita/connectal/bsv/XsimTop.bsv
BSVDEFINES =  -D TRACE_PORTAL -D ConnectalVersion=20.06.4 -D NumberOfMasters=1 -D PinType=Empty -D PinTypeInclude=Misc -D NumberOfUserTiles=1 -D SlaveDataBusWidth=32 -D SlaveControlAddrWidth=5 -D BurstLenSize=10 -D project_dir=$(DTOP) -D MainClockPeriod=20 -D DerivedClockPeriod=10.000000 -D CnocTop -D XsimHostInterface -D PhysAddrWidth=40 -D SIMULATION -D CONNECTAL_BITS_DEPENDENCES=bsim -D BOARD_bluesim
QTUSED = 
export BSVDEFINES_LIST = TRACE_PORTAL ConnectalVersion=20.06.4 NumberOfMasters=1 PinType=Empty PinTypeInclude=Misc NumberOfUserTiles=1 SlaveDataBusWidth=32 SlaveControlAddrWidth=5 BurstLenSize=10 project_dir=$(DTOP) MainClockPeriod=20 DerivedClockPeriod=10.000000 CnocTop XsimHostInterface PhysAddrWidth=40 SIMULATION CONNECTAL_BITS_DEPENDENCES=bsim BOARD_bluesim
export DUT_NAME = mkXsimTop





TRACE_PORTAL=TRACE_PORTAL
ConnectalVersion=20.06.4
NumberOfMasters=1
PinType=Empty
PinTypeInclude=Misc
NumberOfUserTiles=1
SlaveDataBusWidth=32
SlaveControlAddrWidth=5
BurstLenSize=10
project_dir=$(DTOP)
MainClockPeriod=20
DerivedClockPeriod=10.000000
CnocTop=CnocTop
XsimHostInterface=XsimHostInterface
PhysAddrWidth=40
SIMULATION=SIMULATION
CONNECTAL_BITS_DEPENDENCES=bsim
BOARD_bluesim=BOARD_bluesim


include $(CONNECTALDIR)/scripts/Makefile.connectal.build


export VERILOG_PATH=verilog /home/likhita/connectal/verilog $(BLUESPEC_VERILOG)
MODELSIM_FILES= 
FPGAMAKE=$(CONNECTALDIR)/../fpgamake/fpgamake
fpgamake.mk: $(VFILE) Makefile prepare_bin_target
	$(Q)if [ -f ../synth-ip.tcl ]; then vivado -mode batch -source ../synth-ip.tcl; fi
	$(Q)$(FPGAMAKE) $(FPGAMAKE_VERBOSE) -o fpgamake.mk --board=bluesim --part=xc7z020clg484-1  --floorplan=      -t $(MKTOP)   -b hw/mkTop.bit   $(VERILOG_PATH)

synth.%:fpgamake.mk
	$(MAKE) -f fpgamake.mk Synth/$*/$*-synth.dcp

hw/mkTop.bit: prepare_bin_target  fpgamake.mk
	$(Q)mkdir -p hw
	$(Q)$(MAKE) -f fpgamake.mk
ifneq ($(XILINX),)
	$(Q)rsync -rav --include="*/" --include="*.rpt" --exclude="*" Impl/ bin
else ifneq ($(ALTERA),)
	$(Q)cp -f $(MKTOP).sof bin
endif




