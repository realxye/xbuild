#######################################################################
#
# XBUILD MAKEFILE: COMPILER VISUAL STUDIO
#
#     This file define compiler related data, functions and rules
#
########################################################################

ifeq ($(BUILD_TOOLSET),vs2017)
	VSROOT=$(XBUILD_TOOLCHAIN_VS2017)
else ifeq ($(BUILD_TOOLSET),vs2019)
	VSROOT=$(XBUILD_TOOLCHAIN_VS2017)
else ifeq ($(BUILD_TOOLSET),vs2022)
	VSROOT=$(XBUILD_TOOLCHAIN_VS2017)
else
	$(error $(BUILD_TOOLSET) is not supported)
endif

VS_BIN_DIR=$(VSROOT)/VC/Tools/MSVC/$(XBUILD_TOOLCHAIN_VS2022_MSVC_DEFAULT)/bin/Host$(XBUILD_HOST_OSARCH)/$(BUILD_ARCH)

#-----------------------------------#
#			Compiler Tools			#
#-----------------------------------#

BUILDTOOL_C=$(VS_BIN_DIR)/cl.exe
BUILDTOOL_CXX=$(VS_BIN_DIR)/cl.exe
BUILDTOOL_LINK=$(VS_BIN_DIR)/link.exe
BUILDTOOL_LIB=$(VS_BIN_DIR)/lib.exe
ifeq ($(BUILD_ARCH),x64)
    BUILDTOOL_ML=$(VS_BIN_DIR)/ml64.exe
else
    BUILDTOOL_ML=$(VS_BIN_DIR)/ml.exe
endif
BUILDTOOL_RC=$(WDK_BIN_DIR)/rc.exe
BUILDTOOL_MC=$(WDK_BIN_DIR)/mc.exe
BUILDTOOL_MT=$(WDK_BIN_DIR)/mt.exe
BUILDTOOL_MIDL=$(WDK_BIN_DIR)/midl.exe
SIGNTOOL=$(WDK_BIN_DIR)/signtool.exe
PVK2PFX=$(WDK_BIN_DIR)/pvk2pfx.exe
CERT2SPC=$(WDK_BIN_DIR)/cert2spc.exe

#-----------------------------------#
#	Compiler C/C++ Flags: General	#
#-----------------------------------#

# Debug Information Format: default = Zi
ifeq ($(CXXFLAG_DBGINFOFMT),)
	CXXFLAG_DBGINFOFMT=-Zi
endif

# Warning Level: default = level 3
ifeq ($(CXXFLAG_WARN_LEVEL),)
	CXXFLAG_WARN_LEVEL=-W3
endif

# Warning As Error: default = Yes
ifeq ($(CXXFLAG_WARN_AS_ERROR),)
	CXXFLAG_WARN_AS_ERROR=-WX
endif

# Warning Version: default = 18
ifeq ($(CXXFLAG_WARN_VERSION),)
	CXXFLAG_WARN_VERSION=-Wv:18
endif

# Diagnostic Format: default = column
ifeq ($(CXXFLAG_DIAG_FMT),)
	CXXFLAG_DIAG_FMT=-diagnostics:column
endif

# Multi-processor Compilication: default = Yes
ifeq ($(CXXFLAG_MP),)
	CXXFLAG_MP=-MP
endif

# Enable Address Sanitizer: default = No
ifeq ($(CXXFLAG_ADDR_SANIT),)
	CXXFLAG_ADDR_SANIT=
endif

#---------------------------------------#
#	Compiler C/C++ Flags: Optimization	#
#---------------------------------------#

# Optimization: default = O2
ifeq ($(CXXFLAG_OPTIMIZE),)
	CXXFLAG_OPTIMIZE=-O2
endif

# Inline function expansion: default = any suitable
ifeq ($(CXXFLAG_INLINE_FUNCTION),)
	CXXFLAG_INLINE_FUNCTION=-Ob2
endif

# Omit frame pointer: default = no
ifeq ($(CXXFLAG_OMIT_FRAME_POINTER),)
	CXXFLAG_OMIT_FRAME_POINTER=-Oy-
endif

# Whole program optimization: default = Yes
ifeq ($(CXXFLAG_WHOLE_PROGRAM_OPTIMIZATION),)
	CXXFLAG_WHOLE_PROGRAM_OPTIMIZATION=-GL
endif

#---------------------------------------#
#	Compiler C/C++ Flags: Preprocessor	#
#---------------------------------------#

# Use standard conforming preprocessor: default = Yes
ifeq ($(CXXFLAG_STD_PREPROCESSOR),)
	CXXFLAG_STD_PREPROCESSOR=-Zc:preprocessor
endif

#-------------------------------------------#
#	Compiler C/C++ Flags: Code Generation	#
#-------------------------------------------#

# Enable string polling: default = Yes
ifeq ($(CXXFLAG_STR_POLLING),)
	CXXFLAG_STR_POLLING=-GF
endif

# Enable minimal build: default = No
ifeq ($(CXXFLAG_MINIMAL_BUILD),)
	CXXFLAG_MINIMAL_BUILD=-Gm-
endif

# Enable C++ Exceptions: default = Yes
ifeq ($(CXXFLAG_CPP_EXCEPTIONS),)
	CXXFLAG_CPP_EXCEPTIONS=-EHsc
endif

# Enable C++ Exceptions: default = Yes
ifeq ($(CXXFLAG_CPP_EXCEPTIONS),)
	CXXFLAG_CPP_EXCEPTIONS=-EHsc
endif

# Run-time Library: default = MT
ifeq ($(CXXFLAG_RUNTIME_LIB),)
	CXXFLAG_RUNTIME_LIB=-MT
endif

# Security Check: default = Yes
ifeq ($(CXXFLAG_SECURITY_CHECK),)
	CXXFLAG_SECURITY_CHECK=-GS
endif

# Functional Level Linking: default = Yes
ifeq ($(CXXFLAG_FUNCTIONAL_LEVEL_LINKING),)
	CXXFLAG_FUNCTIONAL_LEVEL_LINKING=-Gy
endif

# Floating point model: default = precise
ifeq ($(CXXFLAG_FLOATING_POINT_MODEL),)
	CXXFLAG_FLOATING_POINT_MODEL=-fp:precise
endif

# Spectre Mitigation: default = Yes
ifeq ($(CXXFLAG_SPECTRE_MITIGATION),)
	CXXFLAG_SPECTRE_MITIGATION=-Qspectre
endif

#-------------------------------------------#
#	Compiler C/C++ Flags: Language			#
#-------------------------------------------#

# Treat Wchar_t as Built-in Type: default = Yes
ifeq ($(CXXFLAG_WCHART),)
	CXXFLAG_WCHART=-Zc:wchar_t
endif

# Treat Conformance in For Loop Scope: default = Yes
ifeq ($(CXXFLAG_FOR_SCOPE),)
	CXXFLAG_FOR_SCOPE=-Zc:forScope
endif

# Remove unreferenced code and data: default = Yes
ifeq ($(CXXFLAG_INLINE),)
	CXXFLAG_INLINE=-Zc:inline
endif

# Enable run-time type information: default = Yes
ifeq ($(CXXFLAG_RUNTIME_TYPE_INFO),)
	CXXFLAG_RUNTIME_TYPE_INFO=-GR
endif

# C++ STD LIB: default = Yes
ifeq ($(CXXFLAG_STD_LIB),)
	CXXFLAG_STD_LIB=-std:c++17
endif

# C STD LIB: default = c11 (only valid for VS2019/16.8)
#ifeq ($(CFLAG_STD_LIB),)
#	CFLAG_STD_LIB=-std:c11
#endif

#-------------------------------------------#
#	Compiler C/C++ Flags: Output Files		#
#-------------------------------------------#

# Assembler Output: default = Assembly, Machine Code and Source
ifeq ($(CXXFLAG_ASM_OUTPUT),)
	CXXFLAG_ASM_OUTPUT=-FAcs
endif

# Assembler Output: default = Assembly, Machine Code and Source
ifeq ($(CXXFLAG_ASM_LIST_LOCATION),)
	CXXFLAG_ASM_LIST_LOCATION=$(IntDir)
endif

# Module output file name
ifeq ($(CXXFLAG_MODULE_OUTPUT_LOCATION),)
	CXXFLAG_MODULE_OUTPUT_LOCATION=$(IntDir)
endif

# Module dependency file name
ifeq ($(CXXFLAG_DEPENDENCY_LOCATION),)
	CXXFLAG_DEPENDENCY_LOCATION=$(IntDir)
endif

# Object file name
ifeq ($(CXXFLAG_OBJECT_LOCATION),)
	CXXFLAG_OBJECT_LOCATION=$(IntDir)
endif

# PDB file name
ifeq ($(CXXFLAG_OBJECT_LOCATION),)
	CXXFLAG_PDB_FILE=$(OutDir)$(TargetName).pdb
endif

#-------------------------------------------#
#	Compiler C/C++ Flags: External Includes	#
#-------------------------------------------#

# External header warning level: level 3
ifeq ($(CXXFLAG_EXTERNAL_WARN_LEVEL),)
	CXXFLAG_EXTERNAL_WARN_LEVEL=-external:W3
endif

#-------------------------------------------#
#	Compiler C/C++ Flags: Advanced			#
#-------------------------------------------#

# Calling convention: __cdecl (Gd), __fastcall (Gr), __stdcall (Gz), __vectorcall (Gv)
ifeq ($(CXXFLAG_CALLING_CONVENTION),)
	CXXFLAG_EXTERNAL_WARN_LEVEL=-Gd
endif

# Compile As: C (/TC), C++ (/TP), C++ Module (/interface), C++ Module Internal Partition (/internalPartition), C++ Header Unit (/exportHeader)
ifeq ($(CXXFLAG_CALLING_CONVENTION),)
	CXXFLAG_COMPILE_AS=
endif

# Internal Compile Error: Prompt Immediately (/errorReport:prompt)
ifeq ($(CXXFLAG_CALLING_CONVENTION),)
	CXXFLAG_INTERNAL_COMPILE_ERROR=-errorReport:prompt
endif
