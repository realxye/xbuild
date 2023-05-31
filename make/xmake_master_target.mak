#######################################################################
#
# XWORKSPACE MAKEFILE: MASTER
#
#     This is the master make file
#
########################################################################

# Inlcude common make file
include $(XBUILDROOT)/make/xmake_common.mak

PROJECT_ROOT:=$(project-root)

# Build Dirs
#   - The project root path (e.g. /c/workspace/myproject)
ifeq ($(PROJECT_ROOT),)
	$(error "PROJECT_ROOT is not defined")
endif

# Build Dirs
ifneq ($(ZEROCHECK_BUILD_TYPE),0)
    BUILD_OUTDIR=$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/$(BUILD_TYPE)_$(BUILD_ARCH)/$(TARGET_NAME)
    BUILD_OUTDIR_GEN=$(BUILD_OUTDIR)/generated
    BUILD_OUTDIR_INT=$(BUILD_OUTDIR)/intermediate
endif

#-----------------------------------#
#     Makefile for Specific OS      #
#-----------------------------------#

ifeq ($(XBUILD_HOST_OSNAME),Windows)
    include $(XBUILDROOT)/make/xmake_env_win.mak
else ifeq ($(XBUILD_HOST_OSNAME),Darwin)
    include $(XBUILDROOT)/make/xmake_env_mac.mak
else ifeq ($(XBUILD_HOST_OSNAME),Linux)
    include $(XBUILDROOT)/make/xmake_env_linux.mak
else
    $(error XBUILD_HOST_OSNAME ($(XBUILD_HOST_OSNAME)) is not supported (XBUILD supports Windows, Darwin and Linux))
endif

#-----------------------------------#
#           Make Targets            #
#-----------------------------------#

all: XBUILD_ZERO XBUILD_ALL_TARGETS
	@echo "Target has been built successfully (Used: $(XTIME_DURATION) seconds)"

XBUILD_ZERO:
	@echo "----------------- Build Target: $(TARGET_NAME) ($(BUILD_TOOLSET): $(BUILD_TYPE)/$(BUILD_ARCH)) -----------------" ; \
	echo "Start at `date "+%Y-%m-%d %H:%M:%S"`" ; \
	if [ -z $(TARGET_NAME) ]; then \
		echo "TARGET_NAME is not defined" ; \
		exit 1 ; \
	else \
		if [ ! -z $(BUILD_VERBOSE) ]; then \
			echo "TARGET_NAME: $(TARGET_NAME)" ; \
		fi ; \
	fi ; \
	if [ -z $(BUILD_TOOLSET) ]; then \
		echo "BUILD_TOOLSET is not defined" ; \
		exit 1 ; \
	else \
		if [ ! -z $(BUILD_VERBOSE) ]; then \
			echo "BUILD_TOOLSET: $(BUILD_TOOLSET)" ; \
		fi ; \
	fi ; \
	if [ -z $(BUILD_CONFIG) ]; then \
		echo "BUILD_CONFIG is not defined" ; \
		exit 1 ; \
	else \
		if [ ! -z $(BUILD_VERBOSE) ]; then \
			echo "BUILD_CONFIG: $(BUILD_CONFIG)" ; \
		fi ; \
	fi ; \
	if [ -z $(BUILD_ARCH) ]; then \
		echo "BUILD_ARCH is not defined" ; \
		exit 1 ; \
	else \
		if [ ! -z $(BUILD_VERBOSE) ]; then \
			echo "BUILD_ARCH: $(BUILD_ARCH)" ; \
		fi ; \
	fi

clean:
	@echo '----------------- Clean Target: $(TARGET_NAME) -----------------' ; \
	if [ $(ZEROCHECK_BUILD_TYPE) == 0 ]; then \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_x86/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_x86/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_x86/$(TARGET_NAME)" ; \
		fi ; \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_x64/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_x64/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_x64/$(TARGET_NAME)" ; \
		fi ; \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_arm/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_arm/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_arm/$(TARGET_NAME)" ; \
		fi ; \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_arm64/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_arm64/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/release_arm64/$(TARGET_NAME)" ; \
		fi ; \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_x86/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_x86/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_x86/$(TARGET_NAME)" ; \
		fi ; \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_x64/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_x64/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_x64/$(TARGET_NAME)" ; \
		fi ; \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_arm/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_arm/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_arm/$(TARGET_NAME)" ; \
		fi ; \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_arm64/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_arm64/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/debug_arm64/$(TARGET_NAME)" ; \
		fi ; \
	else \
		if [ -d "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/$(BUILD_TYPE)_$(BUILD_ARCH)/$(TARGET_NAME)" ] ; then \
			echo '  - deleting "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/$(BUILD_TYPE)_$(BUILD_ARCH)/$(TARGET_NAME)" ...'
			rm -rf "$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/$(BUILD_TYPE)_$(BUILD_ARCH)/$(TARGET_NAME)" ; \
		fi ; \
	fi ; \
	echo "Target has been cleaned (Used: $(XTIME_DURATION) seconds)"