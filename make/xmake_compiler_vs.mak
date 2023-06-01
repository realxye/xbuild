#######################################################################
#
# XBUILD MAKEFILE: COMPILER VISUAL STUDIO
#
#     This file define compiler related data, functions and rules
#
########################################################################

ifeq ($(BUILD_TOOLSET),vs2017)
	VSROOT=$(XBUILD_TOOLCHAIN_VS2017)
	VSTOOLSETVER=141
else ifeq ($(BUILD_TOOLSET),vs2019)
	VSROOT=$(XBUILD_TOOLCHAIN_VS2019)
	VSTOOLSETVER=142
else ifeq ($(BUILD_TOOLSET),vs2022)
	VSROOT=$(XBUILD_TOOLCHAIN_VS2022)
	VSTOOLSETVER=143
else
	$(error $(BUILD_TOOLSET) is not supported)
endif

VS_BIN_DIR=$(VSROOT)/VC/Tools/MSVC/$(XBUILD_TOOLCHAIN_VS2022_MSVC_DEFAULT)/bin/Host$(XBUILD_HOST_OSARCH)/$(BUILD_ARCH)
VS_INC_DIR=$(VSROOT)/VC/Tools/MSVC/$(XBUILD_TOOLCHAIN_VS2022_MSVC_DEFAULT)/include
VS_LIB_DIR=$(VSROOT)/VC/Tools/MSVC/$(XBUILD_TOOLCHAIN_VS2022_MSVC_DEFAULT)/lib/$(BUILD_ARCH)
ifeq ($(BUILD_ARCH),$(filter $(BUILD_ARCH),x86 x64))
    # ATL is only valid for x86 and x64
    VS_ATL_INC_DIR=$(VSROOT)/VC/Tools/MSVC/$(XBUILD_TOOLCHAIN_VS2022_MSVC_DEFAULT)/atlmfc/include
    VS_ATL_LIB_DIR=$(VSROOT)/VC/Tools/MSVC/$(XBUILD_TOOLCHAIN_VS2022_MSVC_DEFAULT)/atlmfc/lib/$(BUILD_ARCH)
endif

#####################################
#			Compiler Tools			#
#####################################

BUILDTOOL_CC=$(VS_BIN_DIR)/cl.exe
BUILDTOOL_CXX=$(VS_BIN_DIR)/cl.exe
BUILDTOOL_LINK=$(VS_BIN_DIR)/link.exe
BUILDTOOL_LIB=$(VS_BIN_DIR)/lib.exe
ifeq ($(BUILD_ARCH),x64)
    BUILDTOOL_ML=$(VS_BIN_DIR)/ml64.exe
else
    BUILDTOOL_ML=$(VS_BIN_DIR)/ml.exe
endif

#####################################
#		Directories, Files			#
#####################################

#---------------------------------------#
#	Default Include Dirs				#
#	- Target include dir				#
#	- Target src dir					#
#	- Target generated dir				#
#	- WDK include dirs					#
#	- VC include dir (user only)		#
#	- VC ATL include dir (user only)	#
#	- Dependencies include dir			#
#---------------------------------------#

BUILD_INCDIRS= \
	-Iinclude \
	-Isrc \
	-I"$(BUILD_GENDIR)" \
	-I"$(WDK_INC_DIR)/shared"

ifeq ($(TARGET_MODE),kernel)
    BUILD_INCDIRS += \
		-I"$(WDK_INC_DIR)/km" \
		-I"$(WDK_INC_DIR)/km"
	ifneq ($(WDK_KMDF_INC_DIR),)
        BUILD_INCDIRS += -I"$(WDK_KMDF_INC_DIR)"
	endif
else
    BUILD_INCDIRS += \
		-I"$(WDK_INC_DIR)/um" \
		-I"$(WDK_INC_DIR)/ucrt" \
		-I"$(VS_INC_DIR)"
	ifneq ($(VS_ATL_INC_DIR),)
        BUILD_INCDIRS += -I"$(VS_ATL_INC_DIR)"
	endif
	ifneq ($(WDK_UMDF_INC_DIR),)
        BUILD_INCDIRS += -I"$(WDK_UMDF_INC_DIR)"
	endif
endif

BUILD_INCDIRS += $(foreach f, $(TARGET_DEPENDS), $(addprefix -I", $(addsuffix /include",$f)))
BUILD_INCDIRS += $(foreach f, $(TARGET_EXTRA_INCDIRS), $(addprefix -I", $(addsuffix ",$f)))

#---------------------------------------#
#	Default LIB Dirs					#
#	- Target out dir					#
#	- Target generated dir				#
#	- WDK lib dirs						#
#	- VC lib dir (user only)			#
#	- VC ATL lib dir (user only)		#
#	- Dependencies liv dir				#
#---------------------------------------#

BUILD_LIBDIRS= \
	-LIBPATH:"$(BUILD_GENDIR)" \
	-LIBPATH:"$(BUILD_OUTDIR)"

ifeq ($(TARGET_MODE),kernel)
    BUILD_LIBDIRS += \
		-LIBPATH:"$(WDK_LIB_DIR)/km"
	ifneq ($(WDK_KMDF_LIB_DIR),)
        BUILD_LIBDIRS += -LIBPATH:"$(WDK_KMDF_LIB_DIR)"
	endif
else
    BUILD_LIBDIRS += \
		-LIBPATH:"$(WDK_LIB_DIR)/um" \
		-LIBPATH:"$(WDK_LIB_DIR)/ucrt" \
		-LIBPATH:"$(VS_LIB_DIR)"
	ifneq ($(VS_ATL_LIB_DIR),)
        BUILD_LIBDIRS += -LIBPATH:"$(VS_ATL_LIB_DIR)"
	endif
	ifneq ($(WDK_UMDF_LIB_DIR),)
        BUILD_LIBDIRS += -LIBPATH:"$(WDK_UMDF_LIB_DIR)"
	endif
endif

BUILD_LIBDIRS += $(foreach f, $(TARGET_DEPENDS), $(addprefix -I", $(addsuffix /include",$f)))
BUILD_LIBDIRS += $(foreach f, $(TARGET_EXTRA_LIBDIRS), $(addprefix -I", $(addsuffix ",$f)))

#####################################
#		Compiler C/C++ Flags		#
#####################################

#---------------------------------------#
#	General Flags						#
#---------------------------------------#

# Debug Information Format: default = Zi
ifeq ($(CXXFLAG_DBGINFOFMT),)
	CXXFLAG_DBGINFOFMT=-Zi
else
	ifeq ($(filter $(CXXFLAG_DBGINFOFMT),-Z7 -Zi -ZI),)
		$(error CXXFLAG_DBGINFOFMT ($(CXXFLAG_DBGINFOFMT)) is not supported (Options: -Z7 -Zi -ZI))
	endif
endif

# Warning Level: default = level 3
ifeq ($(CXXFLAG_WARN_LEVEL),)
	CXXFLAG_WARN_LEVEL=-W3
else
	ifeq ($(filter $(CXXFLAG_WARN_LEVEL),-W1 -W2 -W3 -W4 -Wall),)
		$(error CXXFLAG_WARN_LEVEL ($(CXXFLAG_WARN_LEVEL)) is not supported (Options: -W1 -W2 -W3 -W4 -Wall))
	endif
endif

# Warning As Error: default = Yes
ifeq ($(CXXFLAG_WARN_AS_ERROR),)
	CXXFLAG_WARN_AS_ERROR=-WX
else
	ifeq ($(filter $(CXXFLAG_WARN_AS_ERROR),-WX -WX-),)
		$(error CXXFLAG_WARN_AS_ERROR ($(CXXFLAG_WARN_AS_ERROR)) is not supported (Options: -WX -WX-))
	endif
endif

# Warning Version: default = 18
ifeq ($(CXXFLAG_WARN_VERSION),)
	CXXFLAG_WARN_VERSION=-Wv:18
endif

# Diagnostic Format: default = column
ifeq ($(CXXFLAG_DIAG_FMT),)
	CXXFLAG_DIAG_FMT=-diagnostics:column
else
	ifeq ($(filter $(CXXFLAG_DIAG_FMT),-diagnostics:caret -diagnostics:column -diagnostics:classic),)
		$(error CXXFLAG_DIAG_FMT ($(CXXFLAG_DIAG_FMT)) is not supported (Options: -diagnostics:caret -diagnostics:column -diagnostics:classic))
	endif
endif

# Multi-processor Compilication: default = Yes
ifneq ($(filter $(CXXFLAG_MP),no false 0),)
	CXXFLAG_MP=-MP
endif

# Enable Address Sanitizer: default = No
ifneq ($(filter $(CXXFLAG_ADDR_SANIT),yes true 1),)
	CXXFLAG_ADDR_SANIT=-fsanitize=address
endif

#---------------------------------------#
#	Optimization Flags					#
#---------------------------------------#

# Optimization: default = O2
ifeq ($(CXXFLAG_OPTIMIZE),)
	ifeq ($(BUILD_CONFIG),debug)
		CXXFLAG_OPTIMIZE=-Od
	else
		CXXFLAG_OPTIMIZE=-O2
	endif
else
	ifeq ($(filter $(CXXFLAG_OPTIMIZE),-Od -O1 -O2 -Ox),)
		$(error CXXFLAG_OPTIMIZE ($(CXXFLAG_OPTIMIZE)) is not supported (Options: -Od -O1 -O2 -Ox))
	endif
endif

# Inline function expansion: default = any suitable
ifeq ($(CXXFLAG_INLINE_FUNCTION),)
	ifeq ($(BUILD_CONFIG),debug)
		CXXFLAG_INLINE_FUNCTION=-Ob0
	else
		CXXFLAG_INLINE_FUNCTION=-Ob2
	endif
else
	ifeq ($(filter $(CXXFLAG_INLINE_FUNCTION),-Ob0 -Ob1 -Ob2),)
		$(error CXXFLAG_INLINE_FUNCTION ($(CXXFLAG_INLINE_FUNCTION)) is not supported (Options: -Ob0 -Ob1 -Ob2))
	endif
endif

# Enable instrinsic function: default = yes
ifeq ($(filter $(CXXFLAG_ENABLE_INTRINSIC_FUNC),no false 0),)
	CXXFLAG_ENABLE_INTRINSIC_FUNC=-Oi
endif

# Omit frame pointer: default = no
ifeq ($(CXXFLAG_OMIT_FRAME_POINTER),)
	CXXFLAG_OMIT_FRAME_POINTER=-Oy-
else
	ifeq ($(filter $(CXXFLAG_OMIT_FRAME_POINTER),-Oy -Oy-),)
		$(error CXXFLAG_OMIT_FRAME_POINTER ($(CXXFLAG_OMIT_FRAME_POINTER)) is not supported (Options: -Ob0 -Ob1 -Ob2))
	endif
endif

# Whole program optimization: default = Yes
ifneq ($(filter $(CXXFLAG_WHOLE_PROGRAM_OPTIMIZATION),yes true 1),)
	CXXFLAG_WHOLE_PROGRAM_OPTIMIZATION=-GL
endif

#---------------------------------------#
#	Preprocessor Flags					#
#---------------------------------------#

# Use standard conforming preprocessor: default = Yes
ifneq ($(filter $(CXXFLAG_STD_PREPROCESSOR),yes true 1),)
	CXXFLAG_STD_PREPROCESSOR=-Zc:preprocessor
else
	CXXFLAG_STD_PREPROCESSOR=-Zc:preprocessor-
endif

#-------------------------------------------#
#	Code Generation	Flags					#
#-------------------------------------------#

# Enable string polling: default = Yes
ifneq ($(filter $(CXXFLAG_STR_POLLING),yes true 1),)
	CXXFLAG_STR_POLLING=-GF
else
	CXXFLAG_STR_POLLING=-GF-
endif

# Enable minimal build: default = No
ifneq ($(filter $(CXXFLAG_MINIMAL_BUILD),yes true 1),)
	CXXFLAG_MINIMAL_BUILD=-Gm
else
	CXXFLAG_MINIMAL_BUILD=-Gm-
endif

# Enable C++ Exceptions: default = Yes
ifneq ($(filter $(CXXFLAG_CPP_EXCEPTIONS),no false 0),)
	CXXFLAG_CPP_EXCEPTIONS=-EHsc
else
	ifeq ($(CXXFLAG_CPP_EXCEPTIONS),)
		CXXFLAG_CPP_EXCEPTIONS=-EHsc
	else
		ifeq ($(filter $(CXXFLAG_CPP_EXCEPTIONS),false -EHa -EHs -EHsc),)
			$(error CXXFLAG_CPP_EXCEPTIONS ($(CXXFLAG_CPP_EXCEPTIONS)) is not supported (Options: false -EHa -EHs -EHsc))
		endif
	endif
endif

# Run-time Library: default = MT
ifeq ($(CXXFLAG_RUNTIME_LIB),)
    CXXFLAG_RUNTIME_LIB=-MT
endif
ifeq ($(BUILD_CONFIG), debug)
	CXXFLAG_RUNTIME_LIB=$(addsuffix d, $(CXXFLAG_RUNTIME_LIB))
endif

# Security Check: default = Yes
ifneq ($(filter $(CXXFLAG_SECURITY_CHECK),no false 0),)
	CXXFLAG_SECURITY_CHECK=-GS-
else
	CXXFLAG_SECURITY_CHECK=-GS
endif

# Functional Level Linking: default = Yes
ifeq ($(CXXFLAG_FUNCTIONAL_LEVEL_LINKING),)
	CXXFLAG_FUNCTIONAL_LEVEL_LINKING=-Gy
else
	ifeq ($(filter $(CXXFLAG_FUNCTIONAL_LEVEL_LINKING),-Gy -Gy-),)
		$(error CXXFLAG_FUNCTIONAL_LEVEL_LINKING ($(CXXFLAG_FUNCTIONAL_LEVEL_LINKING)) is not supported (Options: -Gy -Gy-))
	endif
endif

# Floating point model: default = precise
ifeq ($(CXXFLAG_FLOATING_POINT_MODEL),)
	CXXFLAG_FLOATING_POINT_MODEL=-fp:precise
else
	ifeq ($(filter $(CXXFLAG_FLOATING_POINT_MODEL),-fp:precise -fp:strict -fp:fast),)
		$(error CXXFLAG_FLOATING_POINT_MODEL ($(CXXFLAG_FLOATING_POINT_MODEL)) is not supported (Options: -fp:precise -fp:strict -fp:fast))
	endif
endif

# Spectre Mitigation: default = Yes
ifeq ($(CXXFLAG_SPECTRE_MITIGATION),)
	CXXFLAG_SPECTRE_MITIGATION=-Qspectre
else
	ifeq ($(filter $(CXXFLAG_SPECTRE_MITIGATION),-Qspectre -Qspectre-load -Qspectre-load-cf),)
		$(error CXXFLAG_SPECTRE_MITIGATION ($(CXXFLAG_SPECTRE_MITIGATION)) is not supported (Options: -Qspectre -Qspectre-load -Qspectre-load-cf))
	endif
endif

#-------------------------------------------#
#	Language Flags							#
#-------------------------------------------#

# Treat Wchar_t as Built-in Type: default = Yes
ifeq ($(CXXFLAG_WCHART),)
	CXXFLAG_WCHART=-Zc:wchar_t
else
	ifeq ($(filter $(CXXFLAG_WCHART),-Zc:wchar_t -Zc:wchar_t-),)
		$(error CXXFLAG_WCHART ($(CXXFLAG_WCHART)) is not supported (Options: -Zc:wchar_t -Zc:wchar_t-))
	endif
endif

# Treat Conformance in For Loop Scope: default = Yes
ifeq ($(CXXFLAG_FOR_SCOPE),)
	CXXFLAG_FOR_SCOPE=-Zc:forScope
else
	ifeq ($(filter $(CXXFLAG_FOR_SCOPE),-Zc:forScope -Zc:forScope-),)
		$(error CXXFLAG_FOR_SCOPE ($(CXXFLAG_FOR_SCOPE)) is not supported (Options: -Zc:forScope -Zc:forScope-))
	endif
endif

# Remove unreferenced code and data: default = Yes (release), No (debug)
ifeq ($(CXXFLAG_REMOVE_UNREF_CODE),)
	ifeq ($(BUILD_CONFIG),release)
		CXXFLAG_REMOVE_UNREF_CODE=-Zc:inline
	endif
endif

# Enable run-time type information: default = Yes
ifeq ($(CXXFLAG_RUNTIME_TYPE_INFO),)
	CXXFLAG_RUNTIME_TYPE_INFO=-GR
else
	ifeq ($(filter $(CXXFLAG_RUNTIME_TYPE_INFO),-GR -GR-),)
		$(error CXXFLAG_RUNTIME_TYPE_INFO ($(CXXFLAG_RUNTIME_TYPE_INFO)) is not supported (Options: -GR -GR-))
	endif
endif

# C++ STD LIB: default = Yes
ifeq ($(CXXFLAG_STD_LIB),)
	CXXFLAG_STD_LIB=-std:c++17
else
	ifeq ($(filter $(CXXFLAG_STD_LIB),-std:c++14 -std:c++17 -std:c++20),)
		$(error CXXFLAG_STD_LIB ($(CXXFLAG_STD_LIB)) is not supported (Options: -std:c++14 -std:c++17 -std:c++20))
	endif
endif

# C STD LIB: default = c11 (only valid for VS2019/16.8)
ifneq ($(CFLAG_STD_LIB),)
    # c11/c17 (only valid for VS2019/16.8 or later)
	ifeq ($(filter $(CFLAG_STD_LIB),-std:c11 -std:c17),)
		$(error CFLAG_STD_LIB ($(CFLAG_STD_LIB)) is not supported (Options: -std:c11 -std:c17))
	endif
endif

#-------------------------------------------#
#	Output Files Flags						#
#-------------------------------------------#

# Assembler Output: default = Assembly, Machine Code and Source
ifeq ($(CXXFLAG_ASM_OUTPUT),)
	CXXFLAG_ASM_OUTPUT=-FAcs
else
	ifeq ($(filter $(CXXFLAG_ASM_OUTPUT),-FA -FAc -FAs -FAcs),)
		$(error CXXFLAG_ASM_OUTPUT ($(CXXFLAG_ASM_OUTPUT)) is not supported (Options: -FA -FAc -FAs -FAcs))
	endif
endif

# Assembler Output: default = Assembly, Machine Code and Source
ifeq ($(CXXFLAG_ASM_LIST_LOCATION),)
	CXXFLAG_ASM_LIST_LOCATION=-Fa"$(subst /,\,$(BUILD_INTDIR))\$(TARGET_NAME).cod"
endif

# Module output file name
ifeq ($(CXXFLAG_MODULE_OUTPUT_LOCATION),)
	CXXFLAG_MODULE_OUTPUT_LOCATION=-ifcOutput"$(subst /,\,$(BUILD_INTDIR))"
endif

# Program database file name
ifeq ($(CXXFLAG_PDB_FILE),)
	CXXFLAG_PDB_FILE=-Fd"$(subst /,\,$(BUILD_INTDIR))\vc$(VSTOOLSETVER).pdb"
endif

# Object file name
#ifeq ($(CXXFLAG_OBJECT_LOCATION),)
#	CXXFLAG_OBJECT_LOCATION=-Fo"$(BUILD_INTDIR)"
#endif

#-------------------------------------------#
#	External Includes Flags					#
#-------------------------------------------#

# External header warning level: level 2
ifeq ($(CXXFLAG_EXTERNAL_WARN_LEVEL),)
	CXXFLAG_EXTERNAL_WARN_LEVEL=-external:W2
else
	ifeq ($(filter $(CXXFLAG_EXTERNAL_WARN_LEVEL),-external:W0 -external:W1 -external:W2 -external:W3 -external:W4),)
		$(error CXXFLAG_EXTERNAL_WARN_LEVEL ($(CXXFLAG_EXTERNAL_WARN_LEVEL)) is not supported (Options: -external:W0 -external:W1 -external:W2 -external:W3 -external:W4))
	endif
endif

#-------------------------------------------#
#	Advanced Flags							#
#-------------------------------------------#

# Calling convention: __cdecl (Gd), __fastcall (Gr), __stdcall (Gz), __vectorcall (Gv)
ifeq ($(CXXFLAG_CALLING_CONVENTION),)
	CXXFLAG_CALLING_CONVENTION=-Gd
else
	ifeq ($(filter $(CXXFLAG_CALLING_CONVENTION),-Gd -Gr -Gz -Gv),)
		$(error CXXFLAG_CALLING_CONVENTION ($(CXXFLAG_CALLING_CONVENTION)) is not supported (Options: -Gd -Gr -Gz -Gv))
	endif
endif

# Compile As: C (/TC), C++ (/TP), C++ Module (/interface), C++ Module Internal Partition (/internalPartition), C++ Header Unit (/exportHeader)
ifeq ($(CXXFLAG_COMPILE_AS),)
	CXXFLAG_COMPILE_AS=
else
	ifeq ($(filter $(CXXFLAG_COMPILE_AS),-TC -TP -interface -internalPartition -exportHeader),)
		$(error CXXFLAG_COMPILE_AS ($(CXXFLAG_COMPILE_AS)) is not supported (Options: -TC -TP -interface -internalPartition -exportHeader))
	endif
endif

# Force include files
ifneq ($(TARGET_FORCE_INCLUDES),)
	CXXFLAG_FORCE_INCLUDES=$(foreach f, $(TARGET_FORCE_INCLUDES), $(addprefix -FI", $(addsuffix ",$f)))
endif

# Ignore Warnings
ifneq ($(TARGET_IGNORE_WARNINGS),)
	CXXFLAG_IGNORE_WARNINGS=$(foreach f, $(TARGET_IGNORE_WARNINGS), $(addprefix -wd", $f))
endif
#	- Ignore Warning: 4018
ifeq ($(filter -wd4018,$(CXXFLAG_IGNORE_WARNINGS)),)
	CXXFLAG_IGNORE_WARNINGS += -wd4018
endif
#	- Ignore Warning: 4244
ifeq ($(filter -wd4244,$(CXXFLAG_IGNORE_WARNINGS)),)
	CXXFLAG_IGNORE_WARNINGS += -wd4244
endif
#	- Ignore Warning: 4267
ifeq ($(filter -wd4267,$(CXXFLAG_IGNORE_WARNINGS)),)
	CXXFLAG_IGNORE_WARNINGS += -wd4267
endif
#	- Ignore Warning: 4731
ifeq ($(filter -wd4731,$(CXXFLAG_IGNORE_WARNINGS)),)
	CXXFLAG_IGNORE_WARNINGS += -wd4731
endif

# Warnings as error
ifneq ($(TARGET_ERROR_WARNINGS),)
	CXXFLAG_ERROR_WARNINGS=$(foreach f, $(TARGET_ERROR_WARNINGS), $(addprefix -we", $f))
endif
#	- Warning as error: 4062
ifeq ($(filter -we4062,$(CXXFLAG_ERROR_WARNINGS)),)
	CXXFLAG_ERROR_WARNINGS += -we4062
endif
#	- Warning as error: 4477
ifeq ($(filter -we4477,$(CXXFLAG_ERROR_WARNINGS)),)
	CXXFLAG_ERROR_WARNINGS += -we4477
endif
#	- Warning as error: 4189
ifeq ($(filter -we4189,$(CXXFLAG_ERROR_WARNINGS)),)
	CXXFLAG_ERROR_WARNINGS += -we4189
endif

# Internal Compile Error: Prompt Immediately (/errorReport:prompt)
ifeq ($(CXXFLAG_INTERNAL_COMPILE_ERROR_REPORT),)
	CXXFLAG_INTERNAL_COMPILE_ERROR_REPORT=-errorReport:prompt
else
	ifeq ($(filter $(CXXFLAG_INTERNAL_COMPILE_ERROR_REPORT),-errorReport:none -errorReport:prompt -errorReport:queue -errorReport:send),)
		$(error CXXFLAG_INTERNAL_COMPILE_ERROR_REPORT ($(CXXFLAG_INTERNAL_COMPILE_ERROR_REPORT)) is not supported (Options: -errorReport:none -errorReport:prompt -errorReport:queue -errorReport:send))
	endif
endif


#-------------------------------------------#
#	Final C/C++ Flags						#
#-------------------------------------------#

BUILD_CXX_FLAGS:= \
	-nologo \
	$(BUILD_INCDIRS) \
	$(CXXFLAG_DBGINFOFMT) \
	$(CXXFLAG_WARN_LEVEL) \
	$(CXXFLAG_WARN_AS_ERROR) \
	$(CXXFLAG_WARN_VERSION) \
	$(CXXFLAG_DIAG_FMT) \
	$(CXXFLAG_MP) \
	$(CXXFLAG_ADDR_SANIT) \
	$(CXXFLAG_OPTIMIZE) \
	$(CXXFLAG_INLINE_FUNCTION) \
	$(CXXFLAG_ENABLE_INTRINSIC_FUNC) \
	$(CXXFLAG_OMIT_FRAME_POINTER) \
	$(CXXFLAG_WHOLE_PROGRAM_OPTIMIZATION) \
	$(CXXFLAG_STD_PREPROCESSOR) \
	$(CXXFLAG_STR_POLLING) \
	$(CXXFLAG_MINIMAL_BUILD) \
	$(CXXFLAG_CPP_EXCEPTIONS) \
	$(CXXFLAG_RUNTIME_LIB) \
	$(CXXFLAG_SECURITY_CHECK) \
	$(CXXFLAG_FUNCTIONAL_LEVEL_LINKING) \
	$(CXXFLAG_FLOATING_POINT_MODEL) \
	$(CXXFLAG_SPECTRE_MITIGATION) \
	$(CXXFLAG_WCHART) \
	$(CXXFLAG_FOR_SCOPE) \
	$(CXXFLAG_REMOVE_UNREF_CODE) \
	$(CXXFLAG_RUNTIME_TYPE_INFO) \
	$(CXXFLAG_STD_LIB) \
	$(CXXFLAG_ASM_OUTPUT) \
	$(CXXFLAG_ASM_LIST_LOCATION) \
	$(CXXFLAG_MODULE_OUTPUT_LOCATION) \
	$(CXXFLAG_DEPENDENCY_LOCATION) \
	$(CXXFLAG_OBJECT_LOCATION) \
	$(CXXFLAG_PDB_FILE) \
	$(CXXFLAG_EXTERNAL_WARN_LEVEL) \
	$(CXXFLAG_CALLING_CONVENTION) \
	$(CXXFLAG_COMPILE_AS) \
	$(CXXFLAG_FORCE_INCLUDES) \
	$(CXXFLAG_IGNORE_WARNINGS) \
	$(CXXFLAG_ERROR_WARNINGS) \
	$(CXXFLAG_INTERNAL_COMPILE_ERROR_REPORT)

BUILD_CC_FLAGS:=$(filter-out $(CXXFLAG_STD_LIB), $(BUILD_CXX_FLAGS)) $(CFLAG_STD_LIB)

#####################################
#		LINK Flags					#
#####################################

#-------------------------------------------#
#	General Flags							#
#-------------------------------------------#

# Output file name
LINKFLAG_OUT_FLAGS=-OUT:"$(subst /,\,$(BUILD_OUTDIR))\$(TARGET_FULLNAME)"

# Incremental linking: debug (yes), release (no)
ifeq ($(LINKFLAG_INCREMENTAL_LINK),)
	ifeq ($(TARGET_CONFIG),release)
		LINKFLAG_INCREMENTAL_LINK=-INCREMENTAL:NO
	else
		LINKFLAG_INCREMENTAL_LINK=-INCREMENTAL
	endif
else
	ifeq ($(filter $(LINKFLAG_INCREMENTAL_LINK),-INCREMENTAL -INCREMENTAL:NO),)
		$(error LINKFLAG_INCREMENTAL_LINK ($(LINKFLAG_INCREMENTAL_LINK)) is not supported (Options: -INCREMENTAL -INCREMENTAL:NO))
	endif
endif

# Incremental Link Database File
ifeq ($(LINKFLAG_INCREMENTAL_LINK),-INCREMENTAL)
	LINKFLAG_INCREMENTAL_LINK_DATABASE=-ILK:$(BUILD_INTDIR)/$(TARGET_NAME).ilk
endif

#-------------------------------------------#
#	Input Flags								#
#-------------------------------------------#

# ignored default lib 
ifeq ($(TARGET_MODE),kernel)
	LINKFLAG_NODEFAULTLIB=-NODEFAULTLIB
else
	ifeq ($(filter $(TARGET_NODEFAULTLIB),yes true 1),$(TARGET_NODEFAULTLIB))
		LINKFLAG_NODEFAULTLIB=-NODEFAULTLIB
	endif
endif

# def file
ifneq ($(TARGET_DEF),)
	LINKFLAG_DEF_FILE=-DEF:"$(TARGET_DEF)"
endif

# defult libs
ifeq ($(TARGET_MODE),kernel)
	LINKFLAG_NODEFAULTLIB=-NODEFAULTLIB
	LINKFLAG_LIBS=fltmgr.lib BufferOverflowK.lib ntoskrnl.lib hal.lib wmilib.lib Ntstrsafe.lib $(TARGET_EXTRA_LIBS)
else
	ifeq ($(filter $(TARGET_NODEFAULTLIB),yes true 1),$(TARGET_NODEFAULTLIB))
		LINKFLAG_NODEFAULTLIB=-NODEFAULTLIB
		LINKFLAG_LIBS=$(TARGET_EXTRA_LIBS)
	else
		LINKFLAG_LIBS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib $(TARGET_EXTRA_LIBS)
	endif
endif

#-------------------------------------------#
#	Manifest								#
#-------------------------------------------#
ifeq ($(TARGET_MODE),kernel)
	LINKFLAG_MANIFEST=-MANIFEST:NO
else
	LINKFLAG_MANIFEST=-MANIFEST
	LINKFLAG_MANIFESTFILE=-MANIFESTFILE:"$(BUILD_INTDIR)/$(TARGET_FULLNAME).intermediate.manifest"
	ifneq ($(filter $(TARGET_ADMIN_PRIVILEGE),yes true 1),)
		LINKFLAG_MANIFESTUAC=-MANIFESTUAC:"level='requireAdministrator' uiAccess='false'"
	else
		LINKFLAG_MANIFESTUAC=-MANIFESTUAC:"level='asInvoker' uiAccess='false'"
	endif
endif

#-------------------------------------------#
#	Debug									#
#-------------------------------------------#

# Debug Information
ifeq ($(LINKFLAG_DEBUG_INFO),)
	LINKFLAG_DEBUG_INFO=-DEBUG:FULL
else
	ifeq ($(filter $(LINKFLAG_DEBUG_INFO),-DEBUG -DEBUG:FASTLINK -DEBUG:FULL),)
		$(error LINKFLAG_DEBUG_INFO ($(LINKFLAG_DEBUG_INFO)) is not supported (Options: -DEBUG -DEBUG:FASTLINK -DEBUG:FULL))
	endif
endif

ifneq ($(LINKFLAG_DEBUG_INFO),)
	LINKFLAG_PDB_FILE=-PDB:"$(BUILD_OUTDIR)/$(TARGET_NAME).pdb"
endif

#-------------------------------------------#
#	System									#
#-------------------------------------------#

# SubSystem
ifeq ($(TARGET_MODE),kernel)
	LINKFLAG_SUBSYSTEM=-SUBSYSTEM:NATIVE
else
	ifeq ($(TARGET_TYPE),console)
		LINKFLAG_SUBSYSTEM=-SUBSYSTEM:CONSOLE
	else
		LINKFLAG_SUBSYSTEM=-SUBSYSTEM:WINDOWS
	endif
endif

# Large Address Aware
LINKFLAG_LARGE_ADDRESS_AWARE=-LARGEADDRESSAWARE

# Driver
ifeq ($(TARGET_MODE),kernel)
	ifeq ($(LINKFLAG_DRIVER),)
		LINKFLAG_DRIVER=-Driver
	else
		ifeq ($(filter $(LINKFLAG_DRIVER),-Driver -DRIVER:UPOMLY -DRIVER:WDM),)
			$(error LINKFLAG_DRIVER ($(LINKFLAG_DRIVER)) is not supported (Options: -Driver -DRIVER:UPOMLY -DRIVER:WDM))
		endif
	endif
endif

#-------------------------------------------#
#	Optimization							#
#-------------------------------------------#

# References
ifeq ($(LINKFLAG_OPTREF),)
	ifeq ($(TARGET_CONFIG),release)
		LINKFLAG_OPTREF=-OPT:REF
	else
		LINKFLAG_OPTREF=-OPT:NOREF
	endif
else
	ifeq ($(filter $(LINKFLAG_OPTREF),-OPT:ICF -OPT:NOICF),)
		$(error LINKFLAG_OPTREF ($(LINKFLAG_OPTREF)) is not supported (Options: -OPT:REF -OPT:NOREF))
	endif
endif

# Enable COMDAT Folding
ifeq ($(LINKFLAG_OPTICF),)
	ifeq ($(TARGET_CONFIG),release)
		LINKFLAG_OPTICF=-OPT:ICF
	else
		LINKFLAG_OPTICF=-OPT:NOICF
	endif
else
	ifeq ($(filter $(LINKFLAG_OPTICF),-OPT:ICF -OPT:NOICF),)
		$(error LINKFLAG_OPTICF ($(LINKFLAG_OPTICF)) is not supported (Options: -OPT:ICF -OPT:NOICF))
	endif
endif

# Profile Guided Database
LINKFLAG_PGD=-PGD:"$(BUILD_INTDIR)/$(TARGET_NAME).pgd"

# Link time code generation
ifneq ($(LINKFLAG_LTCG),)
	ifeq ($(filter $(LINKFLAG_LTCG),-LTCG -LTCG:incremental -LTCG:PGInstrument -LTCG:PGOptimize -LTCG:PGUpdate),)
		$(error LINKFLAG_LTCG ($(LINKFLAG_LTCG)) is not supported (Options: -LTCG -LTCG:incremental -LTCG:PGInstrument -LTCG:PGOptimize -LTCG:PGUpdate))
	endif
	LINKFLAG_LTCG_OBJFILE=-LTCGOUT:"$(BUILD_INTDIR)/$(TARGET_NAME).iobj"
endif

#-------------------------------------------#
#	Advantage								#
#-------------------------------------------#

# Entry Point
ifeq ($(TARGET_MODE),kernel)
    ifeq ($(BUILD_ARCH), x64)
        LINKFLAG_ENTRYPOINT=-ENTRY:"GsDriverEntry"
    else ifeq ($(BUILD_ARCH), x86)
        LINKFLAG_ENTRYPOINT=-ENTRY:"GsDriverEntry@8"
    endif
endif

# Set Checksum
ifeq ($(TARGET_MODE),kernel)
    LINKFLAG_SET_CHECKSUM=-RELEASE
endif

# Dynamic Base
LINKFLAG_DYNAMICBASE=-DYNAMICBASE

# Data Execution Prevention (DEP)
LINKFLAG_DEP=-NXCOMPAT

# Import Library
ifeq ($(TARGET_TYPE),dll)
	LINKFLAG_DLL_IMPORTLIB=-DLL -IMPLIB:"$(BUILD_OUTDIR)/$(TARGET_NAME).lib"
endif

# Merge section
ifeq ($(TARGET_MODE),kernel)
    LINKFLAG_SECTION="INIT,d"
    LINKFLAG_MERGE_SECTION=-MERGE:"_TEXT=.text;_PAGE=PAGE"
endif

# Target Machine
ifeq ($(BUILD_ARCH),x64)
    LINKFLAG_MACHINE=-MACHINE:X64
else ifeq ($(BUILD_ARCH),x86)
    LINKFLAG_MACHINE=-MACHINE:X86
else ifeq ($(BUILD_ARCH),arm)
    LINKFLAG_MACHINE=-MACHINE:ARM
else ifeq ($(BUILD_ARCH),arm64)
    LINKFLAG_MACHINE=-MACHINE:ARM64
endif

# Error reporting
LINKFLAG_ERROR_REPORTING=-ERRORREPORT:PROMPT

# Ignore Errors
ifeq ($(TARGET_MODE),kernel)
    LINKFLAG_IGNORE_WARNINGS=-IGNORE:4078
endif


#-------------------------------------------#
#	Final C/C++ Flags						#
#-------------------------------------------#

BUILD_LINK_FLAGS= \
	-NOLOGO \
	$(LINKFLAG_OUT_FLAGS) \
	$(BUILD_LIBDIRS) \
	$(LINKFLAG_INCREMENTAL_LINK) \
	$(LINKFLAG_INCREMENTAL_LINK_DATABASE) \
	$(LINKFLAG_DEF_FILE) \
	$(LINKFLAG_NODEFAULTLIB) \
	$(LINKFLAG_LIBS) \
	$(LINKFLAG_MANIFEST) \
	$(LINKFLAG_MANIFESTFILE) \
	$(LINKFLAG_MANIFESTUAC) \
	$(LINKFLAG_DEBUG_INFO) \
	$(LINKFLAG_PDB_FILE) \
	$(LINKFLAG_SUBSYSTEM) \
	$(LINKFLAG_LARGE_ADDRESS_AWARE) \
	$(LINKFLAG_DRIVER) \
	$(LINKFLAG_OPTREF) \
	$(LINKFLAG_OPTICF) \
	$(LINKFLAG_PGD) \
	$(LINKFLAG_LTCG) \
	$(LINKFLAG_LTCG_OBJFILE) \
	$(LINKFLAG_ENTRYPOINT) \
	$(LINKFLAG_SET_CHECKSUM) \
	$(LINKFLAG_DYNAMICBASE) \
	$(LINKFLAG_DEP) \
	$(LINKFLAG_SECTION) \
	$(LINKFLAG_MERGE_SECTION) \
	$(LINKFLAG_MACHINE) \
	$(LINKFLAG_ERROR_REPORTING) \
	$(LINKFLAG_IGNORE_WARNINGS)

#####################################
#		LIB Flags					#
#####################################
BUILD_LIB_FLAGS= \
	-NOLOGO \
	$(LINKFLAG_MACHINE) \
	$(LINKFLAG_SUBSYSTEM)

#####################################
#		RC Flags					#
#####################################
ifeq ($(BUILD_ARCH), x64)
    BUILD_RC_FLAGS += -nologo -D_X64_=1 -Damd64=1 -D_WIN64=1 -D_AMD64_=1 -DAMD64=1 -DSTD_CALL $(BUILD_INCDIRS)
else ifeq ($(BUILD_ARCH), x86)
    BUILD_RC_FLAGS  += -nologo -D_X86_=1 -Di386=1 -Dx86=1 -DSTD_CALL $(BUILD_INCDIRS)
endif

ifeq ($(BUILD_MODE),kernel)
    BUILD_RC_FLAGS  += -I"$(WDK_INC_DIR)/um"
endif

#####################################
#		MIDL Flags					#
#####################################
ifeq ($(BUILD_ARCH), x64)
    BUILD_MIDL_FLAGS = -char signed -win64 -x64 -env x64 -Oicf -error all $(BUILD_INCDIRS)
else ifeq ($(BUILD_ARCH), x86)
    BUILD_MIDL_FLAGS = -char signed -win32 -Oicf -error all $(BUILD_INCDIRS)
endif

#####################################
#		ML Flags					#
#####################################

ifeq ($(BUILD_ARCH), x64)
    BUILD_ML_FLAGS = -nologo -Cx -D_M_X64 -DX64
else ifeq ($(BUILD_ARCH), x86)
    BUILD_ML_FLAGS = -nologo -Cx -coff -D_M_X86 -DX86
else
	$(error MASM doesn't support architecture ($(BUILD_ARCH)))
endif

ifeq ($(BUILD_CONFIG),debug)
    BUILD_ML_FLAGS += -Zd
endif

BUILD_ML_FLAGS += $(BUILD_INCDIRS)
