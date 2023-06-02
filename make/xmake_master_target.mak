#######################################################################
#
# XWORKSPACE MAKEFILE: MASTER for TARGET
#
#     This is the master make file
#
########################################################################

# Inlcude common make file
include $(XBUILDROOT)/make/xmake_common.mak

# Build Dirs
#   - The project root path (e.g. C:/workspace/myproject)
ifeq ($(PROJECT_ROOT),)
	$(error "PROJECT_ROOT is not defined")
endif
#   - The target path relative to project root (e.g. src/libraries/common)
ifeq ($(TARGET_PATH),)
	$(error "TARGET_PATH is not defined")
endif

# Build Dirs
ifneq ($(BUILD_CONFIG),)
    BUILD_ROOT=$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/$(BUILD_CONFIG)_$(BUILD_ARCH)
    BUILD_OUTDIR=$(PROJECT_ROOT)/output/build.$(BUILD_TOOLSET)/$(BUILD_CONFIG)_$(BUILD_ARCH)/$(TARGET_PATH)
    BUILD_GENDIR=$(BUILD_OUTDIR)/generated
    BUILD_INTDIR=$(BUILD_OUTDIR)/intermediate
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

all: XBUILD_ZERO $(TARGET_FILENAME) XBUILD_POST_BUILD
	@echo "> Target has been built successfully (Used $(XTIME_DURATION) seconds)"

XBUILD_ZERO:
	@echo "----------------- Build Target: $(TARGET_NAME) ($(BUILD_TOOLSET): $(BUILD_CONFIG)/$(BUILD_ARCH)) -----------------" ; \
	echo "Start at `date "+%Y-%m-%d %H:%M:%S"`" ; \
	echo "> ZeroCheck ..." ; \
	if [ -z $(TARGET_NAME) ]; then \
		echo "    ERROR: TARGET_NAME is not defined" ; \
		exit 1 ; \
	fi ; \
	if [ -z $(BUILD_TOOLSET) ]; then \
		echo "    ERROR: BUILD_TOOLSET is not defined" ; \
		exit 1 ; \
	fi ; \
	if [ -z $(BUILD_CONFIG) ]; then \
		echo "    ERROR: BUILD_CONFIG is not defined" ; \
		exit 1 ; \
	fi ; \
	if [ -z $(BUILD_ARCH) ]; then \
		echo "    ERROR: BUILD_ARCH is not defined" ; \
		exit 1 ; \
	fi ; \
	if [ ! -z $(BUILD_VERBOSE_DBG) ]; then \
		echo "  [Target]" ; \
		echo "    Name:   $(TARGET_NAME)" ; \
		echo "    Type:   $(TARGET_TYPE)" ; \
		echo "  [Build Options]" ; \
		echo "    Toolset:         $(BUILD_TOOLSET)" ; \
		echo "    Config:          $(BUILD_CONFIG)" ; \
		echo "    Architecture:    $(BUILD_ARCH)" ; \
		echo "    OutputDir:       $(BUILD_OUTDIR)" ; \
		echo "    IntermediateDir: $(BUILD_INTDIR)" ; \
		echo "    GeneratedDir:    $(BUILD_GENDIR)" ; \
		echo "  [Build Tools]" ; \
		echo "    CC:              $(BUILDTOOL_CC)" ; \
		echo "    CXX:             $(BUILDTOOL_CXX)" ; \
		echo "    LINK:            $(BUILDTOOL_LINK)" ; \
		echo "    LIB:             $(BUILDTOOL_LIB)" ; \
		echo "    ML:              $(BUILDTOOL_ML)" ; \
		echo "    RC:              $(BUILDTOOL_RC)" ; \
		echo "    MC:              $(BUILDTOOL_MC)" ; \
		echo "    MT:              $(BUILDTOOL_MT)" ; \
		echo "    MIDL:            $(BUILDTOOL_MIDL)" ; \
	fi ; \
	echo "> Compiling ..."

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
	echo "Target has been cleaned (Used $(XTIME_DURATION) seconds)"