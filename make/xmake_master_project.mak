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

ifeq ($(XBUILD_HOST_OSNAME),Windows)
    DRIVE:=$(shell pwd | cut -b 2)
    SUBPATH:=$(shell pwd | cut -c 3-)
    PROJECT_ROOT:=$(DRIVE):$(SUBPATH)
else
    PROJECT_ROOT:=$(shell pwd)
endif
#PROJECT_ROOT:=$(shell pwd)
BUILD_TARGET:=$(target)

#-----------------------------------#
#           Sanity Check            #
#-----------------------------------#

# Project Name
ifeq ($(PROJECT_NAME),)
    $(error PROJECT_NAME is not defined)
endif

# BUILD_ARCH, BUILD_CONFIG and BUILD_TOOLSET are checked in "xmake_common.mak"
# and are guaranteed not empty

LOGFILE:=$(PROJECT_ROOT)/output/$(BUILD_TOOLSET)-$(BUILD_CONFIG)-$(BUILD_ARCH).log
$(info Log: $(LOGFILE))

#-----------------------------------#
#           Make Project            #
#-----------------------------------#

ifeq ($(BUILD_TARGET),)
    PROJECT_TARGETS:=$(PROJECT_LIBS) $(PROJECT_DLLS) $(PROJECT_EXES) $(PROJECT_TESTS)
else
    PROJECT_TARGETS:=$(BUILD_TARGET)
endif

all: XBUILD_ZERO XBUILD_ALL_TARGETS
	@echo " " | tee -a $(LOGFILE) ; \
	echo ">>>>>>>>> PROJECT: $(PROJECT_NAME) ($(BUILD_TOOLSET): $(BUILD_CONFIG)/$(BUILD_ARCH)) HAS BEEN BUILT SUCCESSFULLY <<<<<<<<<" | tee -a $(LOGFILE) ; \
	echo "Duration: $(XTIME_DURATION) seconds" | tee -a $(LOGFILE) ; \
	echo " " | tee -a $(LOGFILE) ; \
	echo " " | tee -a $(LOGFILE)

help:
	@echo "- Make Project" ; \
	echo "    make <arch=x86|x64|arm|arm64> <config=debug|release> [verbose=false|true|debug] [target=path-to-target]" ; \
	echo "- Clean Project" ; \
	echo "    make clean [<arch=x86|x64|arm|arm64 config=debug|release] [verbose=false|true|debug] [target=path-to-target]"

XBUILD_ZERO:
	@if [ ! -d $(PROJECT_ROOT)/output ]; then \
		mkdir -p $(PROJECT_ROOT)/output ; \
	fi ; \
	@echo " " | tee $(LOGFILE) ; \
	echo  "################# BUILD PROJECT: $(PROJECT_NAME) ($(BUILD_TOOLSET): $(BUILD_CONFIG)/$(BUILD_ARCH)) #################" | tee -a $(LOGFILE) ; \
	echo "Start at `date "+%Y-%m-%d %H:%M:%S"`" | tee -a $(LOGFILE) ; \
	echo "Targets:" | tee -a $(LOGFILE) ; \
	$(foreach Target,$(PROJECT_TARGETS), \
		if [ -d "$(PROJECT_ROOT)/$(Target)" ] ; then \
			echo "  - $(Target)" | tee -a $(LOGFILE) ; \
		else \
			echo "  - ERROR: $(Target) not found" | tee -a $(LOGFILE) ; \
			exit 1 ; \
		fi ; \
	)

XBUILD_ALL_TARGETS:
	@echo " " ; \
	$(foreach Target,$(PROJECT_TARGETS), \
		echo " " | tee -a $(LOGFILE) ; \
		echo ">>> TARGET <<<: $(Target)" | tee -a $(LOGFILE) ; \
		if [ -f "$(PROJECT_ROOT)/$(Target)/Makefile" ] ; then \
			cd  "$(PROJECT_ROOT)/$(Target)"; \
			if [ ! -z $(BUILD_VERBOSE) ] ; then \
				echo "  $(XBUILDMAKE) arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(verbose) project-root=$(PROJECT_ROOT) target-path=$(Target)" | tee -a $(LOGFILE) ; \
				$(XBUILDMAKE) arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(verbose) project-root=$(PROJECT_ROOT) target-path=$(Target) || exit 1  ; \
			else \
				$(XBUILDMAKE) arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) project-root=$(PROJECT_ROOT) target-path=$(Target) || exit 1 ; \
			fi ; \
			cd  "$(PROJECT_ROOT)"; \
		else \
			echo "  - ERROR: Makefile not found" | tee -a $(LOGFILE) ; \
			exit 1 ; \
		fi ; \
	)

clean:
	@echo "################# CLEAN PROJECT: $(PROJECT_NAME) #################" ; \
	echo " " ; \
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