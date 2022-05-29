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
        echo Unknown
    fi
}

export XBUILDHOSTOS=`echo \`XBuildGetOS\``

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
