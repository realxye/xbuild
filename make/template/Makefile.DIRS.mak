#######################################################################
#
# TEMPLATE MAKEFILE for DIRs
# Rename this file to 'Makefile'
#
########################################################################

# Build parameters
BUILD_ARCH=$(BuildArch)
BUILD_TYPE=$(BuildType)
BUILD_ROOT=$(BuildRoot)
CURRENT_DIR=$(shell pwd)

ifeq ($(BUILD_ROOT),)
	BUILD_ROOT=$(shell pwd)
endif

# SUBDIRs
# List all the subdirs here
# DIRS= \
#      subdir_1/src \
#      subdir_2/src \
#      subdir_3/test \
#      ...
#      subdir_N/src

DIRS=


#-----------------------------------#
#           Make Targets            #
#-----------------------------------#

# Build all targets
#.PHONY all

# Cleanup all targets
#.PHONY clean

all:
	@for dir in $(DIRS) ; do \
		echo "Build target $(CURRENT_DIR)/$$dir" ; \
	done

clean:
	@echo "Clean"
