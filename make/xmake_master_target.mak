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

LOGFILE:=$(PROJECT_ROOT)/output/$(BUILD_TOOLSET)-$(BUILD_CONFIG)-$(BUILD_ARCH).log

#-----------------------------------#
#           Make Targets            #
#-----------------------------------#

all: XBUILD_ZERO $(TARGET_FILENAME) XBUILD_POST_BUILD
	@echo "> Target has been built successfully (Used $(XTIME_DURATION) seconds)" | tee -a $(LOGFILE)

XBUILD_ZERO:
	@echo "----------------- Build Target: $(TARGET_NAME) ($(BUILD_TOOLSET): $(BUILD_CONFIG)/$(BUILD_ARCH)) -----------------" | tee -a $(LOGFILE) ; \
	echo "Start at `date "+%Y-%m-%d %H:%M:%S"`" | tee -a $(LOGFILE) ; \
	echo "> ZeroCheck ..." | tee -a $(LOGFILE) ; \
	if [ -z $(TARGET_NAME) ]; then \
		echo "    ERROR: TARGET_NAME is not defined" | tee -a $(LOGFILE) ; \
		exit 1 ; \
	fi ; \
	if [ -z $(BUILD_TOOLSET) ]; then \
		echo "    ERROR: BUILD_TOOLSET is not defined" | tee -a $(LOGFILE) ; \
		exit 1 ; \
	fi ; \
	if [ -z $(BUILD_CONFIG) ]; then \
		echo "    ERROR: BUILD_CONFIG is not defined" | tee -a $(LOGFILE) ; \
		exit 1 ; \
	fi ; \
	if [ -z $(BUILD_ARCH) ]; then \
		echo "    ERROR: BUILD_ARCH is not defined" | tee -a $(LOGFILE) ; \
		exit 1 ; \
	fi ; \
	if [ ! -z $(BUILD_VERBOSE_DBG) ]; then \
		echo "  [Target]" | tee -a $(LOGFILE) ; \
		echo "    Name:   $(TARGET_NAME)" | tee -a $(LOGFILE) ; \
		echo "    Type:   $(TARGET_TYPE)" | tee -a $(LOGFILE) ; \
		echo "  [Build Options]" | tee -a $(LOGFILE) ; \
		echo "    Toolset:         $(BUILD_TOOLSET)" | tee -a $(LOGFILE) ; \
		echo "    Config:          $(BUILD_CONFIG)" | tee -a $(LOGFILE) ; \
		echo "    Architecture:    $(BUILD_ARCH)" | tee -a $(LOGFILE) ; \
		echo "    OutputDir:       $(BUILD_OUTDIR)" | tee -a $(LOGFILE) ; \
		echo "    IntermediateDir: $(BUILD_INTDIR)" | tee -a $(LOGFILE) ; \
		echo "    GeneratedDir:    $(BUILD_GENDIR)" | tee -a $(LOGFILE) ; \
		echo "  [Build Tools]" | tee -a $(LOGFILE) ; \
		echo "    CC:              $(BUILDTOOL_CC)" | tee -a $(LOGFILE) ; \
		echo "    CXX:             $(BUILDTOOL_CXX)" | tee -a $(LOGFILE) ; \
		echo "    LINK:            $(BUILDTOOL_LINK)" | tee -a $(LOGFILE) ; \
		echo "    LIB:             $(BUILDTOOL_LIB)" | tee -a $(LOGFILE) ; \
		echo "    ML:              $(BUILDTOOL_ML)" | tee -a $(LOGFILE) ; \
		echo "    RC:              $(BUILDTOOL_RC)" | tee -a $(LOGFILE) ; \
		echo "    MC:              $(BUILDTOOL_MC)" | tee -a $(LOGFILE) ; \
		echo "    MT:              $(BUILDTOOL_MT)" | tee -a $(LOGFILE) ; \
		echo "    MIDL:            $(BUILDTOOL_MIDL)" | tee -a $(LOGFILE) ; \
	fi ; \
	echo "> Compiling ..." | tee -a $(LOGFILE)

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