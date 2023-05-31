#######################################################################
#
# XWORKSPACE MAKEFILE: COMMON
#
#     This file define common data, functions and rules
#
########################################################################

#-----------------------------------#
#              Arguments            #
#-----------------------------------#

# xmake supports following arguments:
#	[Common Arguments]
#		- arch: the build architecture (x86, x64, arm and arm64), generate BUILD_ARCH
#		- config: the build type (debug and release), generate BUILD_CONFIG
#		- toolset: the build toolset (vs/vs2017/vs2019/vs2022, llvm and gcc), generate BUILD_TOOLSET
#		- verbose: show debug information, generate BUILD_VERBOSE
#	[Project Arguments]
#		- target: build specific target, generate BUILD_TARGET
#	[Target Arguments]
#		- project-root: project root path, generate PROJECT_ROOT

BUILD_ARCH:=$(arch)
BUILD_CONFIG:=$(config)
BUILD_TOOLSET:=$(toolset)
BUILD_VERBOSE:=$(verbose)
BUILD_TARGET:=$(target)
PROJECT_ROOT:=$(project-root)

#-----------------------------------#
#           Common Data             #
#-----------------------------------#
XBUILD_OS_NAMES:=Windows Darwin Linux
XBUILD_OS_ARCHS:=x86 x64
XBUILD_ARCHITECTURES:=x86 x64 arm arm64
XBUILD_CONFIGS:=debug release
XBUILD_TOOLSETS:=vs vs2017 vs2019 vs2022 llvm gcc
XBUILD_TARGET_TYPES:=lib dll exe klib kdrv

#-----------------------------------#
#           System Check            #
#-----------------------------------#

# OS Type
ifeq ($(XBUILD_HOST_OSNAME),)
    $(error XBUILD_HOST_OSNAME is not defined (XBUILD supports "$(XBUILD_OS_NAMES)"))
else
	ifeq ($(filter $(XBUILD_HOST_OSNAME),$(XBUILD_OS_NAMES)),)
		$(error XBUILD_HOST_OSNAME ($(XBUILD_HOST_OSNAME)) is not supported (XBUILD supports "$(XBUILD_OS_NAMES)"))
	endif
endif

# OS Archtecture
ifeq ($(XBUILD_HOST_OSARCH),)
    $(error XBUILD_HOST_OSARCH is not defined (XBUILD supports "$(XBUILD_OS_ARCHS)"))
else
	ifeq ($(filter $(XBUILD_HOST_OSARCH),$(XBUILD_OS_ARCHS)),)
		$(error XBUILD_HOST_OSARCH ($(XBUILD_HOST_OSARCH)) is not supported (XBUILD supports "$(XBUILD_OS_ARCHS)"))
	endif
endif

# Ensure BUILD_ARCH and BUILD_CONFIG are set/unset at the same time
ifeq ($(BUILD_ARCH),)
	ifneq ($(BUILD_CONFIG),)
        $(error BUILD_ARCH is not defined while BUILD_CONFIG is defined as $(BUILD_CONFIG), remove BUILD_CONFIG or set BUILD_ARCH ($(XBUILD_ARCHITECTURES)))
	endif
else
	ifeq ($(BUILD_CONFIG),)
        $(error BUILD_CONFIG is not defined while BUILD_ARCH is defined as $(BUILD_ARCH), remove BUILD_ARCH or set BUILD_CONFIG ($(XBUILD_CONFIGS)))
	endif
endif

# Ensure BUILD_ARCH is valid
ifneq ($(BUILD_ARCH),)
	ifeq ($(filter $(BUILD_ARCH),$(XBUILD_ARCHITECTURES)),)
		$(error Ivalid BUILD_ARCH ("$(BUILD_ARCH)"), use one of following: ($(XBUILD_ARCHITECTURES)))
	endif
endif

# Ensure BUILD_ARCH is valid
ifneq ($(BUILD_CONFIG),)
	ifeq ($(filter $(BUILD_CONFIG),$(XBUILD_CONFIGS)),)
		$(error Ivalid BUILD_CONFIG ("$(BUILD_CONFIG)"), use one of following: ($(XBUILD_CONFIGS)))
	endif
endif

# Build Toolset
ifeq ($(BUILD_TOOLSET),)
    ifeq ($(XBUILD_HOST_OSNAME),Windows)
        BUILD_TOOLSET=$(XBUILD_TOOLCHAIN_DEFAULT_VS)
    else ifeq ($(XBUILD_HOST_OSNAME),Darwin)
        BUILD_TOOLSET=llvm
    else ifeq ($(XBUILD_HOST_OSNAME),Linux)
        BUILD_TOOLSET=gcc
    else
        $(error XBUILD_HOST_OSNAME ($(XBUILD_HOST_OSNAME)) is not supported (XBUILD supports Windows, Darwin and Linux))
    endif
endif
ifeq ($(BUILD_TOOLSET),vs)
    BUILD_TOOLSET=$(XBUILD_TOOLCHAIN_DEFAULT_VS)
endif
# Ensure BUILD_ARCH is valid
ifeq ($(filter $(BUILD_TOOLSET),$(XBUILD_TOOLSETS)),)
    $(error Ivalid BUILD_TOOLSET ("$(BUILD_TOOLSET)"), use one of following: ($(XBUILD_TOOLSETS)))
endif

#-----------------------------------#
#			Functions				#
#-----------------------------------#

# Time
XTIME_START:=$(shell echo `date +%s`)
XTIME_CURRENT=$(shell echo `date +%s`)
XTIME_DURATION=$(shell echo $$(( $(XTIME_CURRENT) - $(XTIME_START) )))