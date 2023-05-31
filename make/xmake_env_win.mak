#######################################################################
#
# XBUILD MAKEFILE: Make file for Windows
#
#     This file define Windows environment values
########################################################################

# Target: lib, dll, exe, klib, kdrv
ifeq ($(TARGET_TYPE),lib)
    TARGET_SUFFIX=.lib
else ifeq ($(TARGET_TYPE),dll)
    TARGET_SUFFIX=.dll
else ifeq ($(TARGET_TYPE),exe)
    TARGET_SUFFIX=.exe
else ifeq ($(TARGET_TYPE),klib)
    TARGET_SUFFIX=.lib
else ifeq ($(TARGET_TYPE),kdrv)
    TARGET_SUFFIX=.sys
else
    $(error Invalid TARGET_TYPE ($(TARGET_TYPE)), TARGET_TYPE must be one of following (lib dll exe klib kdrv))
endif

# Target Names
TARGET_FILENAME:=$(TARGET_NAME)$(TARGET_SUFFIX)
TARGET_PDBNAME:=$(TARGET_NAME).pdb
TARGET_PCHNAME:=$(TARGET_NAME).pch
TARGET_DEFNAME:=$(TARGET_NAME).def
TARGET_MANIFESTNAME:=$(TARGET_NAME).manifest

# Windows Kits: path, tools
WDK_BIN_DIR=$(XBUILD_TOOLCHAIN_WDKROOT)/bin/$(XBUILD_TOOLCHAIN_SDK_DEFAULT)/$(BUILD_ARCH)
RC=$(WDK_BIN_DIR)/rc.exe
MC=$(WDK_BIN_DIR)/mc.exe
MT=$(WDK_BIN_DIR)/mt.exe
MIDL=$(WDK_BIN_DIR)/midl.exe
SIGNTOOL=$(WDK_BIN_DIR)/signtool.exe
PVK2PFX=$(WDK_BIN_DIR)/pvk2pfx.exe
CERT2SPC=$(WDK_BIN_DIR)/cert2spc.exe

# Windows platform only support MSBuild and MS-LLVM
ifeq ($(BUILD_TOOLSET),llvm)
    include $(XBUILDROOT)/make/xmake_compiler_llvm.mak
else
    include $(XBUILDROOT)/make/xmake_compiler_vs.mak
endif

# Include make rules
include $(XBUILDROOT)/make/xmake_rules.mak
