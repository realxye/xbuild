#############################################################################
# XBUILD- CORE SCRIPT                                                       #
# This file provides core script function and utils                         #
#############################################################################

# Get current script dir, no matter how it is called
XBuildGetScriptDir()
{
    scriptDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
    echo $scriptDir
}

# Lower-case string
XBuildToLower()
{
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

# Upper-case string
XBuildToUpper()
{
    echo "$1" | sed "y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/"
}

# Get and export os name, currently xbuild only supports following OS
#    - Windows
#    - Linux
#    - MacOS
XBuildGetOS()
{
    UNAMESTR=`XBuildToUpper \`uname -s\``
    if [[ "$UNAMESTR" == MINGW* ]]; then
        echo Windows
    elif [[ "$UNAMESTR" == *LINUX* ]]; then
        echo Linux
    #elif [ "{$UNAMESTR}" == "{FREEBSD}" ]; then
    #    echo FreeBSD
    elif [[ "$UNAMESTR" == DARWIN* ]]; then
        echo MacOS
    else
        echo ""
    fi
}
export XBUILDHOSTOS=`echo \`XBuildGetOS\``

# Get and export os architecture, currently xbuild only supports following
#    - X86
#    - X64
#    - ARM64
XBuildGetOSArch()
{
    UNAMESTR=`XBuildToUpper \`uname -m\``
    if [[ "$UNAMESTR" == X86_64 ]]; then
        echo X64
    elif [[ "$UNAMESTR" == I386 ]]; then
        echo X86
    elif [[ "$UNAMESTR" == ARM ]]; then
        echo ARM
    elif [[ "$UNAMESTR" == ARM64 ]]; then
        echo ARM64
    else
        echo ""
    fi
}
export XBUILDHOSTARCH=`echo \`XBuildGetOSArch\``

XBuildParseArgs()
{
    argc=$#
    argv=("$@")
    for (( i=0; i<argc; i++ )); do
        if [[ "${argv[i]}" == --* ]]; then
            argkey=${argv[i]}
            argvalue=${argv[i+1]}
            if [[ "$argvalue" == --* ]]; then
                argvalue=
            fi
            echo "$argkey=\"$argvalue\""
        fi
    done
}

# Load Windows Core Scripts
if [[ "$XBUILDHOSTOS" == Windows ]]; then
    source "$XBUILDROOT/scripts/xbuild-core-windows.sh"
fi
