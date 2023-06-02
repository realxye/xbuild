#######################################################################
#
# XWORKSPACE MAKEFILE: MASTER for PROJECT
#
#     This is the master make file
#
########################################################################

# Inlcude common make file
include $(XBUILDROOT)/make/xmake_common.mak

#-----------------------------------#
#              Arguments            #
#-----------------------------------#

PROJECT_ROOT:=$(shell pwd)
BUILD_TARGET:=$(target)

#-----------------------------------#
#           Sanity Check            #
#-----------------------------------#

# Project Name
ifeq ($(PROJECT_NAME),)
    $(error PROJECT_NAME is not defined)
endif

#-----------------------------------#
#           Make Project            #
#-----------------------------------#

ifeq ($(BUILD_TARGET),)
    PROJECT_TARGETS:=$(PROJECT_LIBS) $(PROJECT_DLLS) $(PROJECT_EXES) $(PROJECT_TESTS)
else
    PROJECT_TARGETS:=$(BUILD_TARGET)
endif

all: XBUILD_ZERO XBUILD_ALL_TARGETS
	@echo " " ; \
	echo ">>>>>>>>> PROJECT: $(PROJECT_NAME) ($(BUILD_TOOLSET): $(BUILD_CONFIG)/$(BUILD_ARCH)) HAS BEEN BUILT SUCCESSFULLY <<<<<<<<<" ; \
	echo "Duration: $(XTIME_DURATION) seconds" ; \
	echo " " ; \
	echo " "

help:
	@echo "- Make Project"
	@echo "    make <arch=x86|x64|arm|arm64> <config=debug|release> [verbose=false|true|debug] [target=path-to-target]"
	@echo "- Clean Project"
	@echo "    make clean [<arch=x86|x64|arm|arm64 config=debug|release] [verbose=false|true|debug] [target=path-to-target]"

XBUILD_ZERO:
	@echo " " ; \
	echo  "################# BUILD PROJECT: $(PROJECT_NAME) ($(BUILD_TOOLSET): $(BUILD_CONFIG)/$(BUILD_ARCH)) #################" ; \
	echo "Start at `date "+%Y-%m-%d %H:%M:%S"`" ; \
	echo "Targets:" ; \
	$(foreach Target,$(PROJECT_TARGETS), \
		if [ -d "$(PROJECT_ROOT)/$(Target)" ] ; then \
			echo "  - $(Target)" ; \
		else \
			echo "  - ERROR: $(Target) not found" ; \
			exit 1 ; \
		fi ; \
	)

XBUILD_ALL_TARGETS:
	@echo " " ; \
	$(foreach Target,$(PROJECT_TARGETS), \
		echo "> Target: $(Target)" ; \
		if [ -f "$(PROJECT_ROOT)/$(Target)/Makefile" ] ; then \
			cd  "$(PROJECT_ROOT)/$(Target)"; \
			if [ ! -z $(BUILD_VERBOSE) ] ; then \
				echo "  $(XBUILDMAKE) arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(verbose) project-root=$(PROJECT_ROOT) target-path=$(Target)" ; \
				$(XBUILDMAKE) arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(verbose) project-root=$(PROJECT_ROOT) target-path=$(Target) || exit 1 ; \
			else \
				$(XBUILDMAKE) arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) project-root=$(PROJECT_ROOT) target-path=$(Target) || exit 1 ; \
			fi ; \
			cd  "$(PROJECT_ROOT)"; \
		else \
			echo "  - ERROR: Makefile not found" ; \
			exit 1 ; \
		fi ; \
	)

clean:
	@echo "################# CLEAN PROJECT: $(PROJECT_NAME) #################" ; \
	@echo " " ; \
	$(foreach Target,$(PROJECT_TARGETS), \
		echo "> Clean $(Target)" ; \
		if [ -f "$(PROJECT_ROOT)/$(Target)/Makefile" ] ; then \
			cd  "$(PROJECT_ROOT)/$(Target)"; \
			if [ ! -z $(BUILD_VERBOSE) ] ; then \
				echo "  make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(verbose) project-root=$(PROJECT_ROOT) clean" ; \
				make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(verbose) project-root=$(PROJECT_ROOT) ; \
			else \
				make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) project-root=$(PROJECT_ROOT) clean ; \
			fi ; \
			cd  "$(PROJECT_ROOT)"; \
		else \
			echo "  - ERROR: Makefile not found" ; \
			exit 1 ; \
		fi ; \
	)