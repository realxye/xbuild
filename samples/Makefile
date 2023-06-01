#######################################################################
#                                                                     #
# TEMPLATE MAKEFILE for PROJECT                                       #
# Rename this file to 'Makefile' and put it in PROJECT directory      #
#                                                                     #
#######################################################################

PROJECT_NAME=xsamples

#
# List all sub-targets here
#

# All static-library targets, they should be built first
PROJECT_LIBS= \
	libraries/common
#	libraries/sampledll \
#	libraries/samplecom \
#	libraries/kutils

# All dynamic-linked-library targets, they should be built secondly
PROJECT_DLLS= \
#	libraries/kutils \
#	kernel/sampledrv

# All the executables should be built after all libraries have been built 
PROJECT_EXES= \
#	apps/sample \
#	tools/samplectl

# All test targets, they should be built at the last
PROJECT_TESTS= \
#	tests/test_common \
#	tests/test_drv \
#	tests/test_sample


#########################################
#	MASTER MAKEFILE						#
#	NO TARGET SETTINGS BELOW THIS LINE	#
#########################################
include $(XBUILDROOT)/make/xmake_master_project.mak
