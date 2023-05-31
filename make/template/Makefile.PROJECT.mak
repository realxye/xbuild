#######################################################################
#                                                                     #
# TEMPLATE MAKEFILE for PROJECT                                       #
# Rename this file to 'Makefile' and put it in PROJECT directory      #
#                                                                     #
#######################################################################

PROJECT_NAME=

#
# List all sub-targets here
#

# All static-library targets, they should be built first
PROJECT_LIBS=

# All dynamic-linked-library targets, they should be built secondly
PROJECT_DLLS=

# All the executables should be built after all libraries have been built 
PROJECT_EXES=

# All test targets, they should be built at the last
PROJECT_TESTS=

#########################################
#	MASTER MAKEFILE						#
#	NO TARGET SETTINGS BELOW THIS LINE	#
#########################################
include "$(XBUILDROOT)/make/xmake_master_project.mak"

#-----------------------------------#
#           Make Project            #
#-----------------------------------#
