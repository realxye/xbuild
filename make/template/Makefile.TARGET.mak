#######################################################################
#
# TEMPLATE MAKEFILE
# Rename this file to 'Makefile'
#
########################################################################

# Input Build parameters
BUILD_ARCH=$(BuildArch)
BUILD_TYPE=$(BuildType)
BUILD_ROOT=$(BuildRoot)
CURRENT_DIR=$(shell pwd)

ifeq ($(BUILD_ROOT),)
	$(error "BuildRoot is not defined")
endif

# TARGET

TARGET_NAME=
TARGET_TYPE=
TARGET_MODE=


all:
	@echo "BUILD_ARCH =  $(BUILD_ARCH)"
	@echo "BUILD_TYPE =  $(BUILD_TYPE)"
	@echo "BUILD_ROOT =  $(BUILD_ROOT)"

clean:
	@echo "Clean"
