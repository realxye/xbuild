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
	@echo "Target has been built successfully (Used: $(XTIME_DURATION) seconds)"

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
				echo "  make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(BUILD_VERBOSE) project-root=$(PROJECT_ROOT)" ; \
				make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(BUILD_VERBOSE) project-root=$(PROJECT_ROOT) ; \
			else \
				make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) project-root=$(PROJECT_ROOT) ; \
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
				echo "  make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(BUILD_VERBOSE) project-root=$(PROJECT_ROOT) clean" ; \
				make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) verbose=$(BUILD_VERBOSE) project-root=$(PROJECT_ROOT) ; \
			else \
				make arch=$(BUILD_ARCH) config=$(BUILD_CONFIG) toolset=$(BUILD_TOOLSET) project-root=$(PROJECT_ROOT) clean ; \
			fi ; \
			cd  "$(PROJECT_ROOT)"; \
		else \
			echo "  - ERROR: Makefile not found" ; \
			exit 1 ; \
		fi ; \
	)