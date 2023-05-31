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
	src/libraries/common
#	src/libraries/sampledll \
#	src/libraries/samplecom \
#	src/libraries/kutils

# All dynamic-linked-library targets, they should be built secondly
PROJECT_DLLS= \
#	src/libraries/kutils \
#	src/kernel/sampledrv

# All the executables should be built after all libraries have been built 
PROJECT_EXES= \
#	src/apps/sample \
#	src/tools/samplectl

# All test targets, they should be built at the last
PROJECT_TESTS= \
#	src/tests/test_common \
#	src/tests/test_drv \
#	src/tests/test_sample


#########################################
#	MASTER MAKEFILE						#
#	NO TARGET SETTINGS BELOW THIS LINE	#
#########################################
include $(XBUILDROOT)/make/xmake_master_project.mak
