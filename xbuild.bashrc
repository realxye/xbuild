# This bash script should be called from user's .bashrc file
# Add following line into ~/.bashrc file:
#     source <PATH-TO-THIS-FILE>

# Set XBUILDROOT
export XBUILDROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

# Check XBuild profile
if [ ! -f ~/xbuild.profile ]; then
    printf "XBuild profile doesn't exist, try to initialize xbuild ... "
    $( python xbuild.py init  >/dev/null 2>&1)
    #$( touch ~/xbuild.profile >/dev/null 2>&1 )
    if [ -f ~/xbuild.profile ]; then
        printf "Done\n"
    else
        printf "Failed\n"
        return
    fi
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

# Launch xbuild profile
source ~/xbuild.profile

echo "[XBUILD]"
echo "  Toolchain: $XBUILD_TOOLCHAIN_VS"
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

if [ "$XBUILD_TOOLCHAIN_VS" == "" ]; then
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