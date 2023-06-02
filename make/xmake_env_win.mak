#######################################################################
#
# XBUILD MAKEFILE: Make file for Windows
#
#     This file define Windows environment values
########################################################################

# Target: lib, dll, exe, klib, kdrv
ifeq ($(TARGET_TYPE),lib)
    TARGET_SUFFIX=.lib
    TARGET_MODE=user
else ifeq ($(TARGET_TYPE),dll)
    TARGET_SUFFIX=.dll
    TARGET_MODE=user
else ifeq ($(TARGET_TYPE),exe)
    TARGET_SUFFIX=.exe
    TARGET_MODE=user
else ifeq ($(TARGET_TYPE),klib)
    TARGET_SUFFIX=.lib
    TARGET_MODE=kernel
else ifeq ($(TARGET_TYPE),kdrv)
    TARGET_SUFFIX=.sys
    TARGET_MODE=kernel
else
    $(error Invalid TARGET_TYPE ($(TARGET_TYPE)), TARGET_TYPE must be one of following (lib dll exe klib kdrv))
endif

# Target Names
TARGET_FILENAME:=$(TARGET_NAME)$(TARGET_SUFFIX)

# Windows Kits: path, tools
#	- WDK Bin Path
WDK_BIN_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/bin/$(XBUILD_TOOLCHAIN_SDK_DEFAULT)/$(BUILD_ARCH)
#	- WDK Include/Lib Path
ifeq ($(TARGET_MODE),kernel)
    WDK_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/$(XBUILD_TOOLCHAIN_SDK_DEFAULT)
    WDK_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Lib/$(XBUILD_TOOLCHAIN_SDK_DEFAULT)
else
    WDK_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/$(XBUILD_TOOLCHAIN_DDK_DEFAULT)
    WDK_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Lib/$(XBUILD_TOOLCHAIN_DDK_DEFAULT)
endif
#	- WDK KMDF/UMDF Path
ifeq ($(BUILD_ARCH),x86)
	ifneq ($(XBUILD_TOOLCHAIN_KMDF_X86_DEFAULT),)
        WDK_KMDF_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/kmdf/$(XBUILD_TOOLCHAIN_KMDF_X86_DEFAULT)
        WDK_KMDF_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/kmdf/x86/$(XBUILD_TOOLCHAIN_KMDF_X86_DEFAULT)
	endif
	ifneq ($(XBUILD_TOOLCHAIN_UMDF_X86_DEFAULT),)
        WDK_UMDF_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/umdf/$(XBUILD_TOOLCHAIN_UMDF_X86_DEFAULT)
        WDK_UMDF_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/umdf/x86/$(XBUILD_TOOLCHAIN_UMDF_X86_DEFAULT)
	endif
else ifeq ($(BUILD_ARCH),x64)
	ifneq ($(XBUILD_TOOLCHAIN_KMDF_X64_DEFAULT),)
        WDK_KMDF_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/kmdf/$(XBUILD_TOOLCHAIN_KMDF_X64_DEFAULT)
        WDK_KMDF_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/kmdf/x64/$(XBUILD_TOOLCHAIN_KMDF_X64_DEFAULT)
	endif
	ifneq ($(XBUILD_TOOLCHAIN_UMDF_X64_DEFAULT),)
        WDK_UMDF_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/umdf/$(XBUILD_TOOLCHAIN_UMDF_X64_DEFAULT)
        WDK_UMDF_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/umdf/x64/$(XBUILD_TOOLCHAIN_UMDF_X64_DEFAULT)
	endif
else ifeq ($(BUILD_ARCH),arm)
	ifneq ($(XBUILD_TOOLCHAIN_KMDF_ARM_DEFAULT),)
        WDK_KMDF_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/kmdf/$(XBUILD_TOOLCHAIN_KMDF_ARM_DEFAULT)
        WDK_KMDF_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/kmdf/arm/$(XBUILD_TOOLCHAIN_KMDF_ARM_DEFAULT)
	endif
	ifneq ($(XBUILD_TOOLCHAIN_UMDF_ARM_DEFAULT),)
        WDK_UMDF_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/umdf/$(XBUILD_TOOLCHAIN_UMDF_ARM_DEFAULT)
        WDK_UMDF_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/umdf/arm/$(XBUILD_TOOLCHAIN_UMDF_ARM_DEFAULT)
	endif
else ifeq ($(BUILD_ARCH),arm64)
	ifneq ($(XBUILD_TOOLCHAIN_KMDF_ARM64_DEFAULT),)
        WDK_KMDF_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/kmdf/$(XBUILD_TOOLCHAIN_KMDF_ARM64_DEFAULT)
        WDK_KMDF_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/kmdf/arm64/$(XBUILD_TOOLCHAIN_KMDF_ARM64_DEFAULT)
	endif
	ifneq ($(XBUILD_TOOLCHAIN_UMDF_ARM64_DEFAULT),)
        WDK_UMDF_INC_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/umdf/$(XBUILD_TOOLCHAIN_UMDF_ARM64_DEFAULT)
        WDK_UMDF_LIB_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/Include/wdf/umdf/arm64/$(XBUILD_TOOLCHAIN_UMDF_ARM64_DEFAULT)
	endif
else
    WDK_KMDF_INC_DIR=
    WDK_KMDF_LIB_DIR=
    WDK_UMDF_INC_DIR=
    WDK_UMDF_LIB_DIR=
endif
#	- WDK Tools Path
BUILDTOOL_RC=$(WDK_BIN_DIR)/rc.exe
BUILDTOOL_MC=$(WDK_BIN_DIR)/mc.exe
BUILDTOOL_MT=$(WDK_BIN_DIR)/mt.exe
BUILDTOOL_MIDL=$(WDK_BIN_DIR)/midl.exe
BUILDTOOL_SIGNTOOL=$(WDK_BIN_DIR)/signtool.exe
BUILDTOOL_PVK2PFX=$(WDK_BIN_DIR)/pvk2pfx.exe
BUILDTOOL_CERT2SPC=$(WDK_BIN_DIR)/cert2spc.exe

#-----------------------------------#
#		Process Sources	Files		#
#-----------------------------------#

ifneq ($(TARGET_SRCDIR),)
    BUILD_SRCPREFIX:=$(TARGET_SRCDIR)/
endif

# Filter out resource file
TARGET_RCS:=$(filter %.rc, $(TARGET_SOURCES))
ifneq ($(TARGET_RCS),)
    TARGET_SOURCES := $(filter-out $(TARGET_RCS),$(TARGET_SOURCES))
endif

# Filter out IDL file
TARGET_IDLS:=$(filter %.idl, $(TARGET_SOURCES))
ifneq ($(TARGET_IDLS),)
    TARGET_SOURCES := $(filter-out $(TARGET_IDLS),$(TARGET_SOURCES))
endif

# Filter out MANIFEST file
TARGET_MANIFEST:=$(filter %.manifest, $(TARGET_SOURCES))
ifneq ($(TARGET_MANIFEST),)
    TARGET_SOURCES := $(filter-out $(TARGET_MANIFEST),$(TARGET_SOURCES))
endif

# Filter out DEF file
TARGET_DEF:=$(filter %.def, $(TARGET_SOURCES))
ifneq ($(TARGET_DEF),)
    TARGET_SOURCES := $(filter-out $(TARGET_DEF),$(TARGET_SOURCES))
    ifeq ($(TARGETTYPE),dll)
        BUILD_LFLAGS += -DEF:$(TARGET_DEF)
    endif
endif

# Guarantee there are at least one valid source file (c, cc, cxx, cpp, s, asm)
ifeq ($(TARGET_SOURCES),)
    $(error xmake.mak: TARGET_SOURCES is empty)
endif

# Each IDL file generates 4 files: %.tlb, %.h, %_i.c and %_p.c
# Need to add 2 C files to TARGET_SOURCES
ifneq ($(TARGET_IDLS),)
    BUILD_TLBS = $(foreach f, $(TARGTET_IDLS), $(addsuffix .tlb,$(basename $(notdir $f))))
    # IDL files also generate *_i.c and *_p.c
    TARGET_SOURCES += $(foreach f, $(TARGTET_IDLS), $(addsuffix _i.c,$(basename $(notdir $f))))
    TARGET_SOURCES += $(foreach f, $(TARGTET_IDLS), $(addsuffix _p.c,$(basename $(notdir $f))))
endif

#-----------------------------------#
#	Create Intermediate File List	#
#-----------------------------------#

# pch files generated by pre-compiled-header file
ifneq ($(TARGET_PRECOMPILE_HEADER),)
    BUILD_PCH:=$(TARGET_NAME).pch
    BUILD_PCH_OBJ:=xbuild-precompile.o
endif
# tlb files generated by *.idl files
ifneq ($(TARGET_IDLS),)
    BUILD_TLBS:=$(foreach f, $(TARGTET_IDLS), $(addsuffix .tlb,$(basename $(notdir $f))))
endif
# obj files generated by *.c, *.cc, *.cxx, *.cpp, *.s, *.asm files
BUILD_OBJS:=$(foreach f, $(TARGET_SOURCES), $(addsuffix .o,$(basename $f)))
# res files generated by *.rc files
BUILD_RESES:=$(foreach f, $(TARGET_RCS), $(addsuffix .res,$(basename $f)))

#-----------------------------------#
#		Intermediate Targets		#
#-----------------------------------#

# #1: PCH must be 1st target
# #2: TLB must be 2nd target to ensure generated file
# #3: OBJ files
# #4: RES files
BUILD_INTERMEDIATE_TARGETS:=$(BUILD_TLBS) $(BUILD_OBJS) $(BUILD_RESES)

#-----------------------------------#
#			Create Flag List		#
#-----------------------------------#

BUILD_CC_FLAGS=
BUILD_CXX_FLAGS=
BUILD_LIB_FLAGS=
BUILD_LINK_FLAGS=
BUILD_RC_FLAGS=
BUILD_MIDL_FLAGS=


# Windows platform only support MSBuild and MS-LLVM
ifeq ($(BUILD_TOOLSET),llvm)
    include $(XBUILDROOT)/make/xmake_compiler_llvm.mak
else
    include $(XBUILDROOT)/make/xmake_compiler_vs.mak
endif


# Include make rules
#include $(XBUILDROOT)/make/xmake_rules.mak

%.o: $(BUILD_SRCPREFIX)%.s
	@if [ -z '$(patsubst %/,%,$(dir $@))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ; \
		fi \
	fi
	@if [ ! -z '$(BUILD_VERBOSE)' ]; then \
		echo '"$(BUILDTOOL_ML)" $(BUILD_ML_FLAGS) -Fo"$(subst /,\,$(BUILD_INTDIR))\$@" -c $<' ; \
	fi
	@"$(BUILDTOOL_ML)" $(BUILD_ML_FLAGS) -Fo"$(subst /,\,$(BUILD_INTDIR))\$@" -c $< || exit 1

%.o: $(BUILD_SRCPREFIX)%.asm
	@if [ -z '$(patsubst %/,%,$(dir $@))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ; \
		fi \
	fi
	@if [ ! -z '$(BUILD_VERBOSE)' ]; then \
		echo '"$(BUILDTOOL_ML)" $(BUILD_ML_FLAGS) -Fo"$(subst /,\,$(BUILD_INTDIR))\$@" -c $<' ; \
	fi
	@"$(BUILDTOOL_ML)" $(BUILD_ML_FLAGS) -Fo"$(subst /,\,$(BUILD_INTDIR))\$@" -c $< || exit 1

# Rule for building C files
%.o: $(BUILD_SRCPREFIX)%.c
	@if [ -z '$(patsubst %/,%,$(dir $@))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ; \
		fi \
	fi
	@if [ ! -z "$(BUILD_VERBOSE)" ] ; then \
		echo '"$(BUILDTOOL_CC)" $(BUILD_CC_FLAGS) $(CXXFLAG_PCH_USE) -c $< -Fo"$(subst /,\,$(BUILD_INTDIR))\$@"' ; \
	fi
	@"$(BUILDTOOL_CC)" $(BUILD_CC_FLAGS) $(CXXFLAG_PCH_USE) -c $< -Fo"$(subst /,\,$(BUILD_INTDIR))\$@" || exit 1

# Rule for building C++ files
%.o: $(BUILD_SRCPREFIX)%.cpp
	@if [ "$(TARGET_MODE)" = "kernel" ]; then \
		echo "ERROR: XBUILD doesn't support c++ for kernel mode target" ; \
		exit 1 ; \
	fi
	@if [ -z '$(patsubst %/,%,$(dir $@))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ; \
		fi \
	fi
	@if [ ! -z "$(BUILD_VERBOSE)" ]; then \
		echo '"$(BUILDTOOL_CXX)" $(BUILD_CXX_FLAGS) $(CXXFLAG_PCH_USE) -c $< -Fo"$(subst /,\,$(BUILD_INTDIR))\$@"' ; \
	fi
	@"$(BUILDTOOL_CXX)" $(BUILD_CXX_FLAGS) $(CXXFLAG_PCH_USE) -c $< -Fo"$(subst /,\,$(BUILD_INTDIR))\$@" || exit 1

# Rule for Precompiled Header File
$(TARGET_NAME).pch:
	@if [ ! -d $(BUILD_INTDIR) ] ; then \
		mkdir -p $(BUILD_INTDIR) ; \
	fi
	@echo '#include "$(TARGET_PRECOMPILE_HEADER)"' > $(BUILD_INTDIR)/xbuild-precompile.cpp ; \
	if [ ! -z "$(BUILD_VERBOSE)" ] ; then \
		echo '"$(BUILDTOOL_CXX)" $(BUILD_CXX_FLAGS) $(CXXFLAG_PCH_CREATE) -c "$(subst /,\,$(BUILD_INTDIR))\xbuild-precompile.cpp" -Fo"$(subst /,\,$(BUILD_INTDIR))\xbuild-precompile.o"' ; \
	fi
	@"$(BUILDTOOL_CXX)" $(BUILD_CXX_FLAGS) $(CXXFLAG_PCH_CREATE) -c "$(subst /,\,$(BUILD_INTDIR))\xbuild-precompile.cpp" -Fo"$(subst /,\,$(BUILD_INTDIR))\xbuild-precompile.o"

# Rule for building the resources
%.res: $(BUILD_SRCPREFIX)%.rc
	@if [ -z '$(patsubst %/,%,$(dir $@))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ; \
		fi \
	fi
	@if [ ! -z "$(BUILD_VERBOSE)" ] ; then \
		echo '"$(BUILDTOOL_RC)" $(BUILD_RC_FLAGS) -Fo"$(subst /,\,$(BUILD_INTDIR))\$@" $<' ; \
	fi
	@"$(BUILDTOOL_RC)" $(BUILD_RC_FLAGS) -Fo"$(subst /,\,$(BUILD_INTDIR))\$@" $< || exit 1

# Rule for building MIDL files
#	generate 4 files: %.tlb, %.h, %_i.c and %_p.c
%.tlb: $(BUILD_SRCPREFIX)%.idl
	@if [ "$(TARGET_MODE)" = "kernel" ]; then \
		echo "ERROR: XBUILD doesn't support COM for kernel mode target" ; \
		exit 1 ; \
	fi
	@if [ -z '$(patsubst %/,%,$(dir $@))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $@)) ; \
		fi \
	fi
	@if [ ! -z "$(BUILD_VERBOSE)" ] ; then \
		echo '"$(BUILDTOOL_MIDL)" $(BUILD_MIDL_FLAGS) /out $(subst /,\,$(BUILD_INTDIR)) $<' ; \
	fi
	@"$(BUILDTOOL_MIDL)" $(BUILD_MIDL_FLAGS) /out $(subst /,\,$(BUILD_INTDIR)) $< || exit 1

# Rule for link static library
$(TARGET_NAME).lib: $(BUILD_PCH) $(BUILD_INTERMEDIATE_TARGETS)
	@echo "> Linking ..."
	@if [ ! -d $(BUILD_OUTDIR) ] ; then \
		mkdir -p $(BUILD_OUTDIR) ; \
	fi
	@if [ ! -z "$(BUILD_VERBOSE)" ] ; then \
		echo '"$(BUILDTOOL_LIB)" $(BUILD_LIB_FLAGS) -OUT:"$(subst /,\,$(BUILD_OUTDIR))\$@" $(BUILD_INTERMEDIATE_TARGETS)' ; \
	fi
	@"$(BUILDTOOL_LIB)" $(BUILD_LIB_FLAGS) -OUT:"$(subst /,\,$(BUILD_OUTDIR))\$@" $(BUILD_INTERMEDIATE_TARGETS) || exit 1

# Rule for link DLL
$(TARGET_NAME).dll: $(BUILD_PCH) $(BUILD_INTERMEDIATE_TARGETS)
	@echo "> Linking ..."
	@if [ ! -d $(BUILD_OUTDIR) ] ; then \
		mkdir -p $(BUILD_OUTDIR) ; \
	fi
	@if [ ! -z "$(BUILD_VERBOSE)" ] ; then \
		echo '"$(BUILDTOOL_LINK)" $(BUILD_LINK_FLAGS) $(BUILD_PCH_OBJ) $(BUILD_INTERMEDIATE_TARGETS)' ; \
	fi
	@"$(BUILDTOOL_LINK)" $(BUILD_LINK_FLAGS) $(BUILD_PCH_OBJ) $(BUILD_INTERMEDIATE_TARGETS) || exit 1

# Rule for link EXE
$(TARGET_NAME).exe: $(BUILD_PCH) $(BUILD_INTERMEDIATE_TARGETS)
	@echo "> Linking ..."
	@if [ ! -d $(BUILD_OUTDIR) ] ; then \
		mkdir -p $(BUILD_OUTDIR) ; \
	fi
	@if [ ! -z "$(BUILD_VERBOSE)" ] ; then \
		echo '"$(BUILDTOOL_LINK)" $(BUILD_LINK_FLAGS) $(BUILD_PCH_OBJ) $(BUILD_INTERMEDIATE_TARGETS)' ; \
	fi
	@"$(BUILDTOOL_LINK)" $(BUILD_LINK_FLAGS) $(BUILD_PCH_OBJ) $(BUILD_INTERMEDIATE_TARGETS) || exit 1

# Rule for link SYS
$(TARGET_NAME).sys: $(BUILD_PCH) $(BUILD_INTERMEDIATE_TARGETS)
	@echo "> Linking ..."
	@if [ ! -d $(BUILD_OUTDIR) ] ; then \
		mkdir -p $(BUILD_OUTDIR) ; \
	fi
	@if [ ! -z "$(BUILD_VERBOSE)" ] ; then \
		echo '"$(BUILDTOOL_LINK)" $(BUILD_LINK_FLAGS) $(BUILD_PCH_OBJ) $(BUILD_INTERMEDIATE_TARGETS)' ; \
	fi
	@"$(BUILDTOOL_LINK)" $(BUILD_LINK_FLAGS) $(BUILD_PCH_OBJ) $(BUILD_INTERMEDIATE_TARGETS) || exit 1

