#############################################################################
# XBUILD- CORE (WINDOWS) SCRIPT                                             #
# This file provides core script function and utils for Windows             #
#############################################################################

#----------------------------------------------------
# Utils
#----------------------------------------------------

# XBuildWinPathToUnixPath(path)
XBuildWinPathToUnixPath()
{
    subdir=`echo $1 | sed 's/://'`
    if [ $subdir. == . ]; then
        echo ""
    else
        echo "/${subdir//\\//}"
    fi
}

# XBuildGetVersionDirArray(root)
# XBuildGetVersionDirArray returns an array of sub directories order whose name contains only '.' and numbers (0123456789)
# For example, Windows Kits has multiple versions: "10.0.19041.0", "10.0.18362.0", "10.0.17134.0"
# The array items are sorted in DEC order
XBuildGetVersionDirs()
{
    if [ -d "$1" ]; then
        echo `ls "$1" | grep -e "[\.0123456789]" | sed 's/\/$//' | sort -nr`
    fi
}

#----------------------------------------------------
# Get Windows System Dirs
#----------------------------------------------------
XBuildGetWinDir()
{
    dir=`cmd.exe /c "echo %SystemRoot%"`
    echo `XBuildWinPathToUnixPath $dir`
}
#export XBUILD_WINDIR_ROOT=`echo \`XBuildGetWinDir\``

XBuildGetWinDrive()
{
    echo ${XBUILD_WINDIR_ROOT:0:2}
}
#export XBUILD_WINDIR_PROGRAM=`echo \`XBuildGetWinProgramFiles\``

XBuildGetWinProgramFiles86()
{
    if [ -d "$XBUILD_WINDIR_DRIVE/Program Files (x86)" ]; then
        echo "$XBUILD_WINDIR_DRIVE/Program Files (x86)"
    else
        echo "$XBUILD_WINDIR_DRIVE/Program Files"
    fi
}
#export XBUILD_WINDIR_PROGRAM86=`echo \`XBuildGetWinProgramFiles86\``

#----------------------------------------------------
# Get Windows Build Tools
#----------------------------------------------------

# XBuildGetVSRootDir(version)
# Get Visual Studio Installation Root Dir
# Support version: 2017, 2019, 2022
XBuildGetVSRootDir()
{
    if [ $1. == 2017. ]; then
        if [ -f "$XBUILD_WINDIR_PROGRAM86/Microsoft Visual Studio/Installer/vswhere.exe" ]; then
            dir=`"$XBUILD_WINDIR_PROGRAM86/Microsoft Visual Studio/Installer/vswhere.exe" -nologo -version "[15.0,16.0)" -property installationPath`
        fi
    elif [ $1. == 2019. ]; then
        if [ -f "$XBUILD_WINDIR_PROGRAM86/Microsoft Visual Studio/Installer/vswhere.exe" ]; then
            dir=`"$XBUILD_WINDIR_PROGRAM86/Microsoft Visual Studio/Installer/vswhere.exe" -nologo -version "[16.0,17.0)" -property installationPath`
        fi
    elif [ $1. == 2022. ]; then
        if [ -f "$XBUILD_WINDIR_PROGRAM86/Microsoft Visual Studio/Installer/vswhere.exe" ]; then
            dir=`"$XBUILD_WINDIR_PROGRAM86/Microsoft Visual Studio/Installer/vswhere.exe" -nologo -all | grep installationPath | grep 2022 | cut -c 18-`
        fi
    fi
    
    dir=`echo $dir | sed 's/://'`
    
    if [[ $dir. == . ]]; then
        echo ""
    else
        echo "/${dir//\\//}"
    fi
}

#export XBUILD_VS17_ROOT=`echo \`XBuildGetVSRootDir 2022\``
#export XBUILD_VS16_ROOT=`echo \`XBuildGetVSRootDir 2019\``
#export XBUILD_VS15_ROOT=`echo \`XBuildGetVSRootDir 2017\``

#----------------------------------------------------
# Get Windows Kits (SDKs and DDKs)
#----------------------------------------------------

# Get Windows Kits (SDK only) versions
XBuildGetSDK10Versions()
{
    if [ -d "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include" ]; then
        versions=`echo \`XBuildGetVersionDirs "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include"\``
        for item in ${versions}; do
            if [ -d "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/$item/um" ]; then
                result=`echo $result $item`
            fi
        done
    fi
    echo $result
}
#export XBUILD_WINSDK10_VERSIONS=`echo \`XBuildGetSDK10Versions\``

XBuildGetSDK10LatestVersion()
{
    versions=`echo \`XBuildGetSDK10Versions\``
    arr=($versions)
    echo ${arr[0]}
}
#export XBUILD_WINSDK10_DEFAULT_VERSION=`echo \`XBuildGetSDK10LatestVersion\``

# Get Windows Kits (DDK only) versions
XBuildGetDDK10Versions()
{
    if [ -d "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include" ]; then
        versions=`echo \`XBuildGetVersionDirs "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include"\``
        for item in ${versions}; do
            if [ -d "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/$item/km" ]; then
                result=`echo $result $item`
            fi
        done
    fi
    echo $result
}
#export XBUILD_WINDDK10_VERSIONS=`echo \`XBuildGetDDK10Versions\``

XBuildGetDDK10LatestVersion()
{
    versions=`echo \`XBuildGetDDK10Versions\``
    arr=($versions)
    echo ${arr[0]}
}
#export XBUILD_WINDDK10_DEFAULT_VERSION=`echo \`XBuildGetDDK10LatestVersion\``
#export XBUILD_WINDDK10_DEFAULT_BIN=$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/bin/$XBUILD_WINDDK10_DEFAULT_VERSION
#export XBUILD_WINDDK10_DEFAULT_INC=$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/$XBUILD_WINDDK10_DEFAULT_VERSION
#export XBUILD_WINDDK10_DEFAULT_LIB=$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Lib/$XBUILD_WINDDK10_DEFAULT_VERSION

# Get Windows SDK KMDF
XBuildGetKmdfVersions()
{
    if [ -d "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/wdf/kmdf" ]; then
        versions=`echo \`XBuildGetVersionDirs "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/wdf/kmdf"\``
        for item in ${versions}; do
            if [ -f "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/wdf/kmdf/$item/wdf.h" ]; then
                result=`echo $result $item`
            fi
        done
    fi
    echo $result
}
#export XBUILD_WINSDK10_KMDF_VERSIONS=`echo \`XBuildGetKmdfVersions\``

XBuildGetKmdfLatestVersion()
{
    versions=`echo \`XBuildGetKmdfVersions\``
    arr=($versions)
    echo ${arr[0]}
}
#export XBUILD_WINSDK10_KMDF_DEFAULT_VERSION=`echo \`XBuildGetKmdfLatestVersion\``

# Get Windows SDK UMDF
XBuildGetUmdfVersions()
{
    if [ -d "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/wdf/umdf" ]; then
        versions=`echo \`XBuildGetVersionDirs "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/wdf/umdf"\``
        for item in ${versions}; do
            if [ -f "$XBUILD_WINDIR_PROGRAM86/Windows Kits/10/Include/wdf/umdf/$item/wdf.h" ]; then
                result=`echo $result $item`
            fi
        done
    fi
    echo $result
}
#export XBUILD_WINSDK10_UMDF_VERSIONS=`echo \`XBuildGetUmdfVersions\``

XBuildGetUmdfLatestVersion()
{
    versions=`echo \`XBuildGetUmdfVersions\``
    arr=($versions)
    echo ${arr[0]}
}
#export XBUILD_WINSDK10_UMDF_DEFAULT_VERSION=`echo \`XBuildGetUmdfLatestVersion\``

#----------------------------------------------------
# FINALLY: Print Information
#----------------------------------------------------
XBuildWindowsInfo()
{
    echo "[Widnows Paths]" >&2
    echo "  - System Drive:    $XBUILD_WINDIR_DRIVE" >&2
    echo "  - Windows Root:    $XBUILD_WINDIR_ROOT" >&2
    echo "  - Program Files:   $XBUILD_WINDIR_PROGRAM" >&2
    echo "  - Program Files86: $XBUILD_WINDIR_PROGRAM86" >&2
    echo "[Visual Studio]" >&2
    echo "  - VS2022:  $XBUILD_VS17_ROOT" >&2
    echo "  - VS2019:  $XBUILD_VS16_ROOT" >&2
    echo "  - VS2017:  $XBUILD_VS15_ROOT" >&2
    echo "[Windows Kits]" >&2
    echo "  - Available SDKs:  $XBUILD_WINSDK10_VERSIONS" >&2
    echo "  - Default SDK:     $XBUILD_WINSDK10_DEFAULT_VERSION" >&2
    echo "  - Available UMDFs: $XBUILD_WINSDK10_UMDF_VERSIONS" >&2
    echo "  - Default UMDF:    $XBUILD_WINSDK10_UMDF_DEFAULT_VERSION" >&2
    echo "  - Available DDKs:  $XBUILD_WINDDK10_VERSIONS" >&2
    echo "  - Default DDK:     $XBUILD_WINDDK10_DEFAULT_VERSION" >&2
    echo "  - Available KMDFs: $XBUILD_WINSDK10_KMDF_VERSIONS" >&2
    echo "  - Default KMDF:    $XBUILD_WINSDK10_KMDF_DEFAULT_VERSION" >&2
}
# Print
#(XBuildWindowsInfo)
