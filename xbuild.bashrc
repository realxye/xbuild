# This bash script should be called from user's .bashrc file
# Add following line into ~/.bashrc file:
#     source <PATH-TO-THIS-FILE>

# Set XBUILDROOT
export XBUILDROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

# Check XBuild profile
if [ ! -f ~/xbuild.profile ]; then
    printf "XBuild profile doesn't exist, try to initialize xbuild ... "
    # Create xbuild user profiles: ~/xbuild.profile, ~/xbuild.alias
    $( python xbuild.py init >/dev/null 2>&1)
    #$( touch ~/xbuild.profile >/dev/null 2>&1 )
    if [ -f ~/xbuild.profile ]; then
        printf "Done\n"
    else
        printf "Failed\n"
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

# Execute core scripts
source "$XBUILDROOT/scripts/xbuild-core.sh"

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
        echo "ERROR: Fail to generate xbuild-host.pfx"
    fi
    cdx
else
    XBUILD_HOST_PFX=found
fi

#
# Print Information
#
echo "[XBUILD]"
echo "  ROOT: $XBUILDROOT"
echo "  Workspace: $XBUILD_WORKSPACE_ROOT"
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
    echo "XBUILD Warning: Visual Studio not found"
fi
if [ "$XBUILD_TOOLCHAIN_WDKROOT" == "" ]; then
    echo "XBUILD Warning: Windows Kits not found"
else
    if [ "$XBUILD_TOOLCHAIN_SDK_DEFAULT" == "" ]; then
        echo "XBUILD Warning: Windows SDK not found"
    fi
    if [ "$XBUILD_TOOLCHAIN_DDK_DEFAULT" == "" ]; then
        echo "XBUILD Warning: Windows DDK not found"
    fi
fi

if [ "$XBUILD_WORKSPACE_ROOT" == "" ]; then
    echo "XBUILD Warning: Workspace root is not set, change it by updating \"XBUILD_WORKSPACE_ROOT\" variable in \"~/xbuild.profile\""
fi

if [ "$XBUILD_WORKSPACE_ROOT" == "$XBUILDROOT" ]; then
    echo "XBUILD Warning: Workspace root is set to XBUILDROOT, change it by updating \"XBUILD_WORKSPACE_ROOT\" variable in \"~/xbuild.profile\""
fi

if [ -f ~/xbuild-host.pfx ]; then
    HOST_VERT_IN_STORE=`xbuild-findcert`
    #echo "HOST_VERT_IN_STORE=$HOST_VERT_IN_STORE"
    if [ "$HOST_VERT_IN_STORE" == "" ]; then
        echo "XBUILD Warning: XBUILD host certificate file '~/xbuild-host-cert.pem' has NOT been imported, please add it to your system cert store 'Trusted Root Certification Authorities' ..."
        # Following command require Admin privilege
        # certutil.exe -addstore "Root" C:/Users/engineer/xbuild-host-cert.pem
        # certutil.exe -importpfx ~/xbuild-host.pfx
    fi
fi
