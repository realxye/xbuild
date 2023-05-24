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
CURRENT_DIR:=$(shell pwd)

ifeq ($(BUILD_ROOT),)
	BUILD_ROOT:=$(CURRENT_DIR)/output
endif

# SUBDIRs
# List all the subdirs here
# DIRS= \
#      subdir_1/src \
#      subdir_2/src \
#      subdir_3/test \
#      ...
#      subdir_N/src

DIRS= \
	sample_executable \
	sample_dll


#-----------------------------------#
#           Make Targets            #
#-----------------------------------#

all:
	@echo "BUILD_ARCH =  $(BUILD_ARCH)"
	@echo "BUILD_TYPE =  $(BUILD_TYPE)"
	@echo "BUILD_ROOT =  $(BUILD_ROOT)"
	@for DIR in $(DIRS) ; do \
		cd $(CURRENT_DIR)/$$DIR ; \
		make BuildArch=$(BUILD_ARCH) BuildType=$(BUILD_TYPE) BuildRoot=$(BUILD_ROOT)/$$DIR ; \
		cd $(CURRENT_DIR) ; \
	done
	@cd $(CURRENT_DIR)

clean:
	@echo "Clean"
