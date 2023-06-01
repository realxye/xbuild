#######################################################################
#                                                                     #
# TEMPLATE MAKEFILE                                                   #
# Rename this file to 'Makefile' and put in target's directory        #
#                                                                     #
#######################################################################

# Input Build parameters
BUILD_TOOLSET=$(BuildToolset)
BUILD_ARCH=$(BuildArch)
BUILD_TYPE=$(BuildType)
BUILD_ROOT=$(BuildRoot)
TARGET_DIR=$(shell pwd)

ifeq ($(PROJECT_ROOT),)
	$(error "ProjectRoot is not defined")
endif

#
# TARGET
#

#   - Target name
TARGET_NAME=

#   - Target type: lib, dll, console, app, klib, kdrv
#		lib: static library
#		dll: dynamic link lib
#		console: executable without GUI
#		app: executable with GUI
#		klib: kernel mode static library
#		kdrv: kernel mode driver
TARGET_TYPE=

#   - Target dependencies
TARGET_DEPENDS=

#   - Target include directories
#     Don't add include directory for SDK/WDK/Dependencies
TARGET_INCDIRS=

#   - Target library directories
#     Don't add include directory for SDK/WDK/Dependencies
TARGET_LIBDIRS=

#   - Libraries to be linked
TARGET_LIBS=

#   - Precompile header
TARGET_PCH=

#   - Soource Files:
#		*.c
#		*.cxx
#		*.cc
#		*.cpp
#		*.s
#		*.asm
#		*.rc
#		*.manifest
#		*.idl
TARGET_SOURCES=


#########################################
#	MASTER MAKEFILE						#
#	NO TARGET SETTINGS BELOW THIS LINE	#
#########################################
# Include master Makefile
include "$(XBUILDROOT)/make/xmake_master_target.mak"