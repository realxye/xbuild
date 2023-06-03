#############################################################################
# XBUILD- CORE SCRIPT                                                       #
# This file provides core script function and utils                         #
#############################################################################

# Get current script dir, no matter how it is called
xbuild-script-dir()
{
    scriptDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
    echo $scriptDir
}

# Lower-case string
xbuild-lower()
{
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

# Upper-case string
xbuild-upper()
{
    echo "$1" | sed "y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/"
}

# Get and export os name, currently xbuild only supports following OS
#    - Windows
#    - Linux
#    - Darwin
xbuild-get-osname()
{
    UNAMESTR=`XBuildToUpper \`uname -s\``
    if [[ "$UNAMESTR" == MINGW* ]]; then
        echo Windows
    elif [[ "$UNAMESTR" == MSYS_NT* ]]; then
        echo Windows
    elif [[ "$UNAMESTR" == *LINUX* ]]; then
        echo Linux
    elif [[ "$UNAMESTR" == DARWIN* ]]; then
        echo Darwin
    else
        echo ""
    fi
}

# Get and export os architecture, currently xbuild only supports following
#    - x86
#    - x64
#    - arm
#    - arm64
xbuild-get-hostarch()
{
    UNAMESTR=`XBuildToUpper \`uname -m\``
    if [[ "$UNAMESTR" == X86_64 ]]; then
        echo x64
    elif [[ "$UNAMESTR" == I386 ]]; then
        echo x86
    elif [[ "$UNAMESTR" == ARM ]]; then
        echo arm
    elif [[ "$UNAMESTR" == ARM64 ]]; then
        echo arm64
    else
        echo ""
    fi
}

xbuild-parse-args()
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

xbuild-start-ssh()
{
    SSH_ENV=$HOME/.ssh/environment
    SSH_EXIST=true
    
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || SSH_EXIST=false
    else
        SSH_EXIST=false
    fi

    if [ $SSH_EXIST. == false. ]; then
        echo "Initializing new SSH agent..."
        # spawn ssh-agent
        /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
        echo "  - succeeded"
        chmod 600 "${SSH_ENV}"
        . "${SSH_ENV}" > /dev/null
        # ADD YOUR SSH CERTS
        keys=`echo \`ls ~/.ssh | grep .pub\``
        for k in ${keys}; do
            echo "Adding cert: ~/.ssh/${k::-4}"
            /usr/bin/ssh-add ~/.ssh/${k::-4}
        done
    fi
    echo "SSH agent is running"
}

xbuild-create()
{
    if [ $1. == . ]; then
        echo "ERROR: parameter 1 (TYPE) is not set, try \"XBuildCreate <project|module> <name> \""
        return
    fi
    
    if [ $2. == . ]; then
        echo "ERROR: parameter 2 (NAME) is not set, try \"XBuildCreate <project|module> <name> \""
        return
    fi

    if [ $1. == project. ]; then
        # Create project folder if it doesn't exist
        if [ -d $2 ]; then
            echo "WARNING: target folder already exist"
        else
            mkdir $2 || return
        fi
        # Copy project makefile
        cp $XBUILDROOT/make/template/Makefile.PROJECT.mak $2/Makefile || return
        # Generate README.md file
        if [ ! -f $2/README.md ]; then
            echo "PROJECT $2" > $2/README.md
        fi
        # Generate .gitignore file
        if [ ! -f $2/.gitignore ]; then
            cp $XBUILDROOT/make/template/gitignore.txt $2/.gitignore
        else
            echo "WARNING: target folder already exist"
        fi
    elif [ $1. == module. ]; then
        if [ -d $2 ]; then
            echo "ERROR: \".gitignore\" already exists, use following command to force generate:"
            echo "cat $XBUILDROOT/make/template/gitignore.txt >> $2/.gitignore"
            return
        fi
        # Create module folder
        mkdir $2 || return
        # Copy module makefile
        cp $XBUILDROOT/make/template/Makefile.TARGET.mak $2/Makefile || return
        # Make sub-folders
        mkdir $2/src
        mkdir $2/include
    else
        echo "ERROR: parameter 1 (TYPE) is invalid, use \"project\" or \"module\""
        return
    fi
}
