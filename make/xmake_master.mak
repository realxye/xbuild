#######################################################################
#
# XWORKSPACE MAKEFILE: MASTER
#
#     This is the master make file
#
########################################################################

#-----------------------------------#
#           Sanity Check            #
#-----------------------------------#

# Target Name
ifeq ($(TARGET_NAME),)
    $(error TARGET_NAME is not defined)
endif

# Target Name
ifeq ($(TARGET_TYPE),)
    $(error TARGET_TYPE is not defined (exe, dll, lib, driver, klib))
endif

# Build Arch
ifeq ($(BUILD_ARCH),)
    $(error BUILD_ARCH is not defined (x86, x64))
endif

# Build Arch
ifeq ($(BUILD_TYPE),)
    $(error BUILD_TYPE is not defined (release, debug))
endif

#-----------------------------------#
#           Make Targets            #
#-----------------------------------#

# Build all targets
.PHONY all

# Build zero check
.PHONY zerocheck

# Cleanup all targets
.PHONY clean