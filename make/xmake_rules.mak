#######################################################################
#
# XWORKSPACE MAKEFILE: MASTER
#
#     This is the master make file
#
########################################################################

#-----------------------------------#
#		  	Make Rules				#
#-----------------------------------#

# Rule for building ASM files
%.o: %.s
	@if [ -z '$(patsubst %/,%,$(dir $<))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ; \
		fi \
	fi
	@if [ "$(VERBOSE)" = "yes" ]; then \
		echo '"$(TOOL_ML)" $(BUILD_MLFLAGS) -Fo "$(BUILD_INTDIR)/$@" -c $<' ; \
	fi
	@"$(TOOL_ML)" $(BUILD_MLFLAGS) -Fo "$(BUILD_INTDIR)/$@" -c $< || exit 1

%.o: %.asm
	@if [ -z '$(patsubst %/,%,$(dir $<))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ; \
		fi \
	fi
	@if [ "$(VERBOSE)" = "yes" ] ; then \
		echo '"$(TOOL_ML)" $(BUILD_MLFLAGS) -Fo "$(BUILD_INTDIR)/$@" -c $<' ; \
	fi
	@"$(TOOL_ML)" $(BUILD_MLFLAGS) -Fo "$(BUILD_INTDIR)/$@" -c $< || exit 1

# Rule for building C files
%.o: %.c
	@if [ -z '$(patsubst %/,%,$(dir $<))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ; \
		fi \
	fi
	@if [ "$(VERBOSE)" = "yes" ] ; then \
		echo '"$(TOOL_CC)" $(BUILD_CFLAGS) -c $< -Fo"$(BUILD_INTDIR)/$@"' ; \
	fi
	@"$(TOOL_CC)" $(BUILD_CFLAGS) -c $< -Fo"$(BUILD_INTDIR)/$@" || exit 1


# Rule for building C++ files
%.o: %.cpp
	@if [ -z '$(patsubst %/,%,$(dir $<))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ; \
		fi \
	fi
	@if [ "$(VERBOSE)" = "yes" ]; then \
		echo '"$(TOOL_CXX)" $(BUILD_CXXFLAGS) $(USE_PCHFLAG) -c $< -Fo$(BUILD_INTDIR)/$@' ; \
	fi
	@"$(TOOL_CXX)" $(BUILD_CXXFLAGS) $(USE_PCHFLAG) -c $< -Fo$(BUILD_INTDIR)/$@ || exit 1

# Rule for Precompiled Header File
$(TARGETNAME).pch:
	@if [ ! -d $(BUILD_INTDIR) ] ; then \
		mkdir -p $(BUILD_INTDIR) ; \
	fi
	@if [ "$(TARGETMODE)" = "kernel" ] ; then \
		echo '#include "$(TARGET_PCHNAME)"' > $(BUILD_INTDIR)/$(TARGET_PCHBASENAME).c ; \
		if [ "$(VERBOSE)" = "yes" ] ; then \
			echo '"$(TOOL_CC)" $(BUILD_CXXFLAGS) $(CREATE_PCHFLAG) -c "$(BUILD_INTDIR)/$(TARGET_PCHBASENAME).c" -Fo"$(BUILD_INTDIR)/$(TARGET_PCHBASENAME).o"' ; \
		fi ; \
		"$(TOOL_CC)" $(BUILD_CXXFLAGS) $(CREATE_PCHFLAG) -c "$(BUILD_INTDIR)/$(TARGET_PCHBASENAME).c" -Fo"$(BUILD_INTDIR)/$(TARGET_PCHBASENAME).o" || exit 1 ; \
	else \
		echo '#include "$(TARGET_PCHNAME)"' > $(BUILD_INTDIR)/$(TARGET_PCHBASENAME).cpp ; \
		if [ "$(VERBOSE)" = "yes" ] ; then \
			echo '"$(TOOL_CXX)" $(BUILD_CXXFLAGS) $(CREATE_PCHFLAG) -c "$(BUILD_INTDIR)/$(TARGET_PCHBASENAME).cpp" -Fo"$(BUILD_INTDIR)/$(TARGET_PCHBASENAME).o"' ; \
		fi ; \
		"$(TOOL_CXX)" $(BUILD_CXXFLAGS) $(CREATE_PCHFLAG) -c "$(BUILD_INTDIR)/$(TARGET_PCHBASENAME).cpp" -Fo"$(BUILD_INTDIR)/$(TARGET_PCHBASENAME).o" || exit 1 ; \
	fi

# Rule for building the resources
%.res: %.rc
	@if [ -z '$(patsubst %/,%,$(dir $<))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ; \
		fi \
	fi
	@if [ "$(VERBOSE)" = "yes" ] ; then \
		echo '"$(TOOL_RC)" $(BUILD_RCFLAGS) -Fo $(BUILD_INTDIR)/$@ $<' ; \
	fi
	@"$(TOOL_RC)" $(BUILD_RCFLAGS) -Fo $(BUILD_INTDIR)/$@ $< || exit 1

# Rule for building MIDL files
#	generate 4 files: %.tlb, %.h, %_i.c and %_p.c
%.tlb: %.idl
	@if [ -z '$(patsubst %/,%,$(dir $<))' ]; then \
		if [ ! -d $(BUILD_INTDIR) ] ; then \
			mkdir -p $(BUILD_INTDIR) ; \
		fi \
	else \
		if [ ! -d $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ] ; then \
			mkdir -p $(BUILD_INTDIR)/$(patsubst %/,%,$(dir $<)) ; \
		fi \
	fi
	@if [ "$(VERBOSE)" = "yes" ] ; then \
		echo '"$(TOOL_MIDL)" $(BUILD_MIDLFLAGS) /out $(BUILD_INTDIR) $<' ; \
	fi
	@"$(TOOL_MIDL)" $(BUILD_MIDLFLAGS) /out $(BUILD_INTDIR) $< || exit 1

# Rule to build final target
$(TARGETNAME)$(TARGETEXT): $(ALLTARGETS)
	@echo "> Linking ..."
	@if [ ! -d $(BUILD_OUTDIR) ] ; then \
		mkdir -p $(BUILD_OUTDIR) ; \
	fi
	@if [ "$(TARGETTYPE)" = "lib" ] || [ "$(TARGETTYPE)" = "klib" ] ; then \
		if [ "$(VERBOSE)" = "yes" ] ; then \
			echo '"$(TOOL_LIB)" $(BUILD_SLFLAGS) -OUT:"$(BUILD_INTDIR)/$(TARGETNAME)$(TARGETEXT)"' ; \
		fi ; \
		"$(TOOL_LIB)" $(BUILD_SLFLAGS) -OUT:"$(BUILD_INTDIR)/$(TARGETNAME)$(TARGETEXT)" ; \
		echo "> Copying files ..." ; \
		cp "$(BUILD_INTDIR)/$(TARGETNAME)$(TARGETEXT)" "$(BUILD_OUTDIR)/$(TARGETNAME)$(TARGETEXT)" ; \
		echo "     $(BUILD_OUTDIR)/$(TARGETNAME)$(TARGETEXT)" ; \
	else \
		if [ "$(VERBOSE)" = "yes" ] ; then \
			echo '"$(TOOL_LINK)" $(BUILD_LFLAGS) -OUT:"$(BUILD_INTDIR)/$(TARGETNAME)$(TARGETEXT)"' ; \
		fi ; \
		"$(TOOL_LINK)" $(BUILD_LFLAGS) -OUT:"$(BUILD_INTDIR)/$(TARGETNAME)$(TARGETEXT)" ; \
		if [ -n '$(BUILDSIGNARGS)' ]; then \
		    echo '> Signing output ...' ; \
			if [ "$(VERBOSE)" = "yes" ] ; then \
		    	echo '"$(TOOL_SIGNTOOL)" $(BUILDSIGNARGS) "$(BUILD_INTDIR)/$(TARGETNAME)$(TARGETEXT)"' ; \
			fi ; \
			"$(TOOL_SIGNTOOL)" $(BUILDSIGNARGS) "$(BUILD_INTDIR)/$(TARGETNAME)$(TARGETEXT)"; \
		fi ; \
		echo "> Copying files ..." ; \
		cp "$(BUILD_INTDIR)/$(TARGETNAME)$(TARGETEXT)" "$(BUILD_OUTDIR)/$(TARGETNAME)$(TARGETEXT)" ; \
		echo "     $(BUILD_OUTDIR)/$(TARGETNAME)$(TARGETEXT)" ; \
		cp "$(BUILD_INTDIR)/$(TARGETNAME).pdb" "$(BUILD_OUTDIR)/$(TARGETNAME).pdb" ; \
		echo "     $(BUILD_OUTDIR)/$(TARGETNAME).pdb" ; \
	fi
	@if [ "$(TARGETTYPE)" = "dll" ] ; then \
		cp "$(BUILD_INTDIR)/$(TARGETNAME).lib" "$(BUILD_OUTDIR)/$(TARGETNAME).lib" ; \
		echo "     $(BUILD_OUTDIR)/$(TARGETNAME).lib" ; \
	fi
