# This bash script should be called from user's .bashrc file
# Add following line into ~/.bashrc file:
#     source <PATH-TO-THIS-FILE>

# Set XBUILDROOT
export XBUILDROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

# Execute core scripts
source "$XBUILDROOT/scripts/xbuild-core.sh"

# Export some common bash color settings
#   - End
export BASHCOLOR_END="\e[0m"
#   - Normal
export BASHCOLOR_RED="\e[31m"
export BASHCOLOR_GREEN="\e[32m"
export BASHCOLOR_YELLOW="\e[33m"
export BASHCOLOR_BLUE="\e[34m"
export BASHCOLOR_MAGENTA="\e[35m"
export BASHCOLOR_CYAN="\e[36m"
export BASHCOLOR_LIGHT_GRAY="\e[37m"
export BASHCOLOR_GRAY="\e[90m"
export BASHCOLOR_LIGHT_RED="\e[91m"
export BASHCOLOR_LIGHT_GREEN="\e[92m"
export BASHCOLOR_LIGHT_YELLOW="\e[93m"
export BASHCOLOR_LIGHT_BLUE="\e[94m"
export BASHCOLOR_LIGHT_MAGENTA="\e[95m"
export BASHCOLOR_LIGHT_CYAN="\e[96m"
export BASHCOLOR_WHITE="\e[97m"
#   - Bold
export BASHCOLOR_BOLD_RED="\e[1;31m"
export BASHCOLOR_BOLD_GREEN="\e[1;32m"
export BASHCOLOR_BOLD_YELLOW="\e[1;33m"
export BASHCOLOR_BOLD_BLUE="\e[1;34m"
export BASHCOLOR_BOLD_MAGENTA="\e[1;35m"
export BASHCOLOR_BOLD_CYAN="\e[1;36m"
export BASHCOLOR_BOLD_LIGHT_GRAY="\e[1;37m"
export BASHCOLOR_BOLD_GRAY="\e[1;90m"
export BASHCOLOR_BOLD_LIGHT_RED="\e[1;91m"
export BASHCOLOR_BOLD_LIGHT_GREEN="\e[1;92m"
export BASHCOLOR_BOLD_LIGHT_YELLOW="\e[1;93m"
export BASHCOLOR_BOLD_LIGHT_BLUE="\e[1;94m"
export BASHCOLOR_BOLD_LIGHT_MAGENTA="\e[1;95m"
export BASHCOLOR_BOLD_LIGHT_CYAN="\e[1;96m"
export BASHCOLOR_BOLD_WHITE="\e[1;97m"
#   - Italics
export BASHCOLOR_ITALIC_RED="\e[3;31m"
export BASHCOLOR_ITALIC_GREEN="\e[3;32m"
export BASHCOLOR_ITALIC_YELLOW="\e[3;33m"
export BASHCOLOR_ITALIC_BLUE="\e[3;34m"
export BASHCOLOR_ITALIC_MAGENTA="\e[3;35m"
export BASHCOLOR_ITALIC_CYAN="\e[3;36m"
export BASHCOLOR_ITALIC_LIGHT_GRAY="\e[3;37m"
export BASHCOLOR_ITALIC_GRAY="\e[3;90m"
export BASHCOLOR_ITALIC_LIGHT_RED="\e[3;91m"
export BASHCOLOR_ITALIC_LIGHT_GREEN="\e[3;92m"
export BASHCOLOR_ITALIC_LIGHT_YELLOW="\ee[3;93m"
export BASHCOLOR_ITALIC_LIGHT_BLUE="\e[3;94m"
export BASHCOLOR_ITALIC_LIGHT_MAGENTA="\e[3;95m"
export BASHCOLOR_ITALIC_LIGHT_CYAN="\e[3;96m"
export BASHCOLOR_ITALIC_WHITE="\e[3;97m"

# Check XBuild profile
if [ ! -f ~/xbuild.profile ]; then
    xbuild-print "XBuild profile doesn't exist, try to initialize xbuild ... "
    # Create xbuild user profiles: ~/xbuild.profile, ~/xbuild.alias
    $( python xbuild.py init >/dev/null 2>&1)
    #$( touch ~/xbuild.profile >/dev/null 2>&1 )
    if [ -f ~/xbuild.profile ]; then
        xbuild-print "Done"
    else
        xbuild-print "Failed" red b
        return
    fi
else
    # Always ensure alias file exist
    $( python xbuild.py init alias >/dev/null 2>&1)
fi

# Append xbuild bashrc
XBUILD_BASHRC="$XBUILDROOT/xbuild\.bashrc"
#echo "XBUILD_BASHRC=\"$XBUILD_BASHRC\""
XBUILD_BASHRC_INVOKE=$( cat ~/.bashrc | grep "$XBUILD_BASHRC" )
#echo "XBUILD_BASHRC_INVOKE=\"$XBUILD_BASHRC_INVOKE\""
if [ "$XBUILD_BASHRC_INVOKE" == "" ]; then
    echo "Add xbuild.bashrc to user bash profile"
    echo "" >> ~/.bashrc
    echo "# XBUILD bash profile" >> ~/.bashrc
    echo "source \"$XBUILDROOT/xbuild.bashrc\"" >> ~/.bashrc
    echo "" >> ~/.bashrc
fi

# Launch xbuild profile and alias
source ~/xbuild.profile
if [ -f ~/xbuild.alias ]; then
    source ~/xbuild.alias
fi

# Export Xbuild Tools
if [ "$XBUILD_HOST_OSNAME" == "Windows" ]; then
    export XBUILDMAKE=$XBUILDROOT/tools/make/windows/bin/make.exe
else
    export XBUILDMAKE=make
fi

#
# Fix Mac Bash Color
#
if [ "$XBUILD_HOST_OSNAME" == "Darwin" ]; then
    parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    #export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "
    export CLICOLOR=1
    export LSCOLORS=ExFxBxDxCxegedabagacad
    alias ls='ls -GFh'
fi

#
# Start ssh-agent
#
xbuild-start-ssh

#
# Disable MINGWIN auto path conversion
#
export MSYS_NO_PATHCONV=1
XBUILD_HOST_PASSWORD=`xbuild-hostpassword`

if [ ! -f ~/xbuild-host.pfx ]; then
    cd ~/
    xbuild-gencert xbuild-host
    if [ -f xbuild-host.pfx ]; then
        XBUILD_HOST_PFX=created
    else
        xbuild-print "ERROR: Fail to generate xbuild-host.pfx" red b
    fi
    cdx
else
    XBUILD_HOST_PFX=found
fi

# Get Git root
XBUILD_GIT_ROOT=`xbuild-getgitroot`

#
# Print Information
#
echo "[XBUILD]"
echo "  ROOT: $XBUILDROOT"
echo "  Workspace: $XBUILD_WORKSPACE_ROOT"
echo "  Git: $XBUILD_GIT_ROOT"
echo "  Make: $XBUILDMAKE"
echo "  Toolchain: $XBUILD_TOOLCHAIN_DEFAULT_VS"
echo "  WDK: $XBUILD_TOOLCHAIN_WDKROOT"
if [ "$XBUILD_TOOLCHAIN_SDK_DEFAULT" == "" ]; then
    echo "  SDK:"
else
    echo "  SDK: $XBUILD_TOOLCHAIN_SDK_DEFAULT ($XBUILD_TOOLCHAIN_SDK_VERSIONS)"
fi
if [ "$XBUILD_TOOLCHAIN_DDK_DEFAULT" == "" ]; then
    echo "  DDK:"
else
    echo "  DDK: $XBUILD_TOOLCHAIN_DDK_DEFAULT ($XBUILD_TOOLCHAIN_DDK_VERSIONS)"
fi
echo "  UMDF (x86): $XBUILD_TOOLCHAIN_UMDF_X86_DEFAULT"
echo "  UMDF (x64): $XBUILD_TOOLCHAIN_UMDF_X64_DEFAULT"
echo "  UMDF (arm): $XBUILD_TOOLCHAIN_UMDF_ARM_DEFAULT"
echo "  UMDF (arm64): $XBUILD_TOOLCHAIN_UMDF_ARM64_DEFAULT"
echo "  KMDF (x86): $XBUILD_TOOLCHAIN_KMDF_X86_DEFAULT"
echo "  KMDF (x64): $XBUILD_TOOLCHAIN_KMDF_X64_DEFAULT"
echo "  KMDF (arm): $XBUILD_TOOLCHAIN_KMDF_ARM_DEFAULT"
echo "  KMDF (arm64): $XBUILD_TOOLCHAIN_KMDF_ARM64_DEFAULT"
echo " "

#
# Post checking
#
if [ "$XBUILD_TOOLCHAIN_DEFAULT_VS" == "" ]; then
    xbuild-print "XBUILD Warning: Visual Studio not found" yellow i
fi
if [ "$XBUILD_TOOLCHAIN_WDKROOT" == "" ]; then
    xbuild-print "XBUILD Warning: Windows Kits not found" yellow i
else
    if [ "$XBUILD_TOOLCHAIN_SDK_DEFAULT" == "" ]; then
        xbuild-print "XBUILD Warning: Windows SDK not found" yellow i
    fi
    if [ "$XBUILD_TOOLCHAIN_DDK_DEFAULT" == "" ]; then
        xbuild-print "XBUILD Warning: Windows DDK not found" yellow i
    fi
fi

if [ "$XBUILD_WORKSPACE_ROOT" == "" ]; then
    xbuild-print "XBUILD Warning: Workspace root is not set, change it by updating \"XBUILD_WORKSPACE_ROOT\" variable in \"~/xbuild.profile\"" yellow i
fi

if [ "$XBUILD_WORKSPACE_ROOT" == "$XBUILDROOT" ]; then
    xbuild-print "XBUILD Warning: Workspace root is set to XBUILDROOT, change it by updating \"XBUILD_WORKSPACE_ROOT\" variable in \"~/xbuild.profile\"" yellow i
fi

if [ -f ~/xbuild-host.pfx ]; then
    HOST_VERT_IN_STORE=`xbuild-findcert`
    #echo "HOST_VERT_IN_STORE=$HOST_VERT_IN_STORE"
    if [ "$HOST_VERT_IN_STORE" == "" ]; then
        xbuild-print "XBUILD Warning: XBUILD host certificate file '~/xbuild-host-cert.pem' has NOT been imported, please add it to your system cert store 'Trusted Root Certification Authorities' ..." yellow i
        # Following command require Admin privilege
        # certutil.exe -addstore "Root" C:/Users/engineer/xbuild-host-cert.pem
        # certutil.exe -importpfx ~/xbuild-host.pfx
    fi
fi


# Ensure Git is installed and make is copied
if [ "$XBUILD_GIT_ROOT" == "" ]; then
    xbuild-print "XBUILD Warning: Git is not found" red b
else
    if [ $XBUILD_HOST_OSNAME == Windows ]; then
        if [ ! -f "$XBUILD_GIT_ROOT/usr/bin/make.exe" ]; then
            xbuild-print "XBUILD Warning: make.exe is not found in Git, copy xbuild make to Git" yellow i
            cp "$XBUILDROOT/tools/make/windows/bin/make.exe" "$XBUILD_GIT_ROOT/usr/bin/make.exe" || echo "ERROR: Fail to copy, try command: 'cp \"$XBUILDROOT/tools/make/windows/bin/make.exe\" \"$XBUILD_GIT_ROOT/usr/bin/make.exe\"'"
        fi
    fi
fi