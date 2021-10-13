
include $(CLEAR_VARS)
DTOP?=/home/likhita/connectal/examples/IIR_Fil/bluesim
CONNECTALDIR?=/home/likhita/connectal
LOCAL_ARM_MODE := arm
include $(CONNECTALDIR)/scripts/Makefile.connectal.application
LOCAL_SRC_FILES := /home/likhita/connectal/examples/IIR_Fil/testfilter.cpp /home/likhita/connectal/cpp/dmaManager.c /home/likhita/connectal/cpp/platformMemory.cpp /home/likhita/connectal/cpp/transportXsim.c $(PORTAL_SRC_FILES)

LOCAL_PATH :=
LOCAL_MODULE := android.exe
LOCAL_MODULE_TAGS := optional
LOCAL_LDLIBS := -llog   
LOCAL_CPPFLAGS := "-march=armv7-a"
LOCAL_CFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CXXFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CFLAGS2 := $(cdefines2)s

include $(BUILD_EXECUTABLE)
