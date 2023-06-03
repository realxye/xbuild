#######################################################################
#                                                                     #
# TEMPLATE MAKEFILE                                                   #
# Rename this file to 'Makefile' and put in target's directory        #
#                                                                     #
#######################################################################

#
# TARGET
#

#   - Target name
TARGET_NAME=common

#   - Target type: lib, dll, console, app, klib, kdrv
#		lib: static library
#		dll: dynamic link lib
#		console: executable without GUI
#		app: executable with GUI
#		klib: kernel mode static library
#		kdrv: kernel mode driver
TARGET_TYPE=lib

#   - Other project modules that Target depends on (Must be modules in same project)
TARGET_DEPENDS=

#   - Target include directories
#     Don't add include directory for SDK/WDK/Dependencies
TARGET_EXTRA_INCDIRS=

#   - Target force include files
TARGET_FORCE_INCLUDES=

#   - Target library directories
#     Don't add include directory for SDK/WDK/Dependencies
TARGET_EXTRA_LIBDIRS=

#   - Libraries to be linked
TARGET_EXTRA_LIBS=

#   - Target definitions
TARGET_DEFINES=

#   - Precompile Header File (e.g. src/pch.h)
TARGET_PRECOMPILE_HEADER=

#   - Ignore warnings
TARGET_IGNORE_WARNINGS=

#   - Require Admin Privilege
TARGET_ADMIN_PRIVILEGE=

#   - Warnings as errors
TARGET_ERROR_WARNINGS=

# By default, 
TARGET_SRCDIR=src

#   - Source Files:
#		*.c
#		*.cxx
#		*.cc
#		*.cpp
#		*.s
#		*.asm
#		*.rc
#		*.manifest
#		*.idl
TARGET_SOURCES= \
    util.cpp \
    version.cpp

#########################################
#	MASTER MAKEFILE						#
#	NO TARGET SETTINGS BELOW THIS LINE	#
#########################################
# Include master Makefile
include $(XBUILDROOT)/make/xmake_master_target.mak

XBUILD_POST_BUILD:
	@echo "> Post Processing ..."
