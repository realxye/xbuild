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

xbuild-hostpassword()
{
    KEY=`echo -n $USERNAME@$HOSTNAME | md5sum`
    KEYARRAY=($KEY)
    echo ${KEYARRAY[0]}
}

xbuild-encrypt()
{
    if [ $1. == . ]; then
        echo "ERROR: parameter 1 (SOURCE) is not set, try \"xbuild-encrypt <source> [encrypted-file] \""
        return
    fi

    if [ ! -f $1 ]; then
        echo "ERROR: parameter 1 (SOURCE) is not a valid file"
        return
    fi

    INFILE=$1

    if [ $2. == . ]; then
        OUTFILE=$1.enc
    else
        if [ -f $2 ]; then
            echo "ERROR: parameter 2 (OUTFILE) already exist"
            return
        fi
        OUTFILE=$2
    fi

    PSWD=`xbuild-hostpassword`
    openssl aes-256-cbc -a -salt -pbkdf2 -pass pass:$PSWD -in $INFILE -out $OUTFILE
}

xbuild-decrypt()
{
    if [ $1. == . ]; then
        echo "ERROR: parameter 1 (SOURCE) is not set, try \"xbuild-decrypt <source> [decrypted-file] \""
        return
    fi

    if [ ! -f $1 ]; then
        echo "ERROR: parameter 1 (SOURCE) is not a valid file"
        return
    fi

    INFILE=$1

    if [ $2. == . ]; then
        OUTFILE=$1.new
    else
        if [ -f $2 ]; then
            echo "ERROR: parameter 2 (OUTFILE) already exist"
            return
        fi
        OUTFILE=$2
    fi

    PSWD=`xbuild-hostpassword`
    openssl aes-256-cbc -d -a -pbkdf2 -pass pass:$PSWD -in $INFILE -out $OUTFILE
}

xbuild-gencert()
{
    if [ $1. == . ]; then
        KEYNAME=xbuild
    else
        KEYNAME=$1
    fi

    PRIKEY=$KEYNAME-private.key
    PUBCERT=$KEYNAME-cert.pem
    PFXCERT=$KEYNAME.pfx

    if [ -f $PRIKEY ]; then
        echo "ERROR: $PRIKEY already exist"
        return
    fi
    if [ -f $PUBCERT ]; then
        echo "ERROR: $PUBCERT already exist"
        return
    fi
    if [ -f $PFXCERT ]; then
        echo "ERROR: $PFXCERT already exist"
        return
    fi

    PSWD=`xbuild-hostpassword`
    OU_NAME=`xbuild-lower $HOSTNAME`
    CN_NAME=`xbuild-lower $USERNAME.$HOSTNAME`

    # generate private RSA key and public certificate
    openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 -keyout $PRIKEY -out $PUBCERT -subj "/C=US/ST=California/L=San Mateo/O=XBUILD/OU=$OU_NAME/CN=$CN_NAME"
    if [ ! -f $PRIKEY ]; then
        echo "ERROR: Fail to create private key: $PRIKEY"
        return
    fi
    if [ ! -f $PUBCERT ]; then
        echo "ERROR: Fail to create certificate: $PUBCERT"
        return
    fi

    # generate PFX file
    openssl pkcs12 -export -out $PFXCERT -inkey $PRIKEY --passout pass:$PSWD -in $PUBCERT
    if [ ! -f $PFXCERT ]; then
        echo "ERROR: Fail to create PFX file: $PFXCERT"
        rm $PRIKEY
        rm $PUBCERT
        return
    fi

    echo "SUCCEEDED: PFX key ($PFXCERT) has been created successfully"
}

xbuild-findcert()
{
    CERTUTIL=certutil.exe
    CN_NAME=`xbuild-lower $USERNAME.$HOSTNAME`
    CERTFILTER="Issuer: CN=$CN_NAME"
    CERTRESULT=`$CERTUTIL -store ROOT | grep "$CERTFILTER"`
    echo -n "$CERTRESULT"
}

# Convert unix path to dos path
xbuild-unix2dospath()
{
    if [ "$1." == "." ]; then
        echo "$1"
        return
    fi

    UNIXPATH=$1
    
    if [ ${UNIXPATH:0:1}. == /. ]; then
        if [ ${UNIXPATH:2:1}. == /. ]; then
            DRIVE=`xbuild-upper ${UNIXPATH:1:1}`
            echo "$DRIVE:${UNIXPATH:2}"
            return
        fi
    fi
    
    # Otherwise, it is not unix-style Windows Path
    echo "$1"
}

xbuild-sign()
{
    if [ "$1." == "." ]; then
        echo "ERROR: target file parameter not set. Try 'xbuild-sign <file>'"
        return
    fi
    if [ ! -f "$1" ]; then
        echo "ERROR: target file does not exist"
        return
    fi
    if [ $XBUILD_HOST_PASSWORD. == . ]; then
        echo "ERROR: Password not found"
    fi
    PFXCERT=`echo ~/xbuild-host.pfx`
    PFXCERT_DOS=`xbuild-unix2dospath "$PFXCERT"`
    if [ ! -f ~/xbuild-host.pfx ]; then
        echo "ERROR: PFX Certificate (~/xbuild-host.pfx) not found"
        return
    fi

    SIGNTOOL=$XBUILD_TOOLCHAIN_WDKROOT/bin/$XBUILD_TOOLCHAIN_SDK_DEFAULT/x64/signtool.exe
    if [ ! -f "$SIGNTOOL" ]; then
        echo "ERROR: SignTool (\"$SIGNTOOL\") not found"
        return
    fi

    echo "\"$SIGNTOOL\" sign /f \"$PFXCERT_DOS\" /fd SHA256 /p $XBUILD_HOST_PASSWORD \" $1\""
    "$SIGNTOOL" sign /f "$PFXCERT_DOS" /fd SHA256 /p $XBUILD_HOST_PASSWORD "$1"
}

xbuild-create()
{
    if [ $1. == . ]; then
        echo "ERROR: parameter 1 (TYPE) is not set, try \"xbuild-create <project|module> <name> [--force] \""
        return
    fi
    
    if [ $2. == . ]; then
        echo "ERROR: parameter 2 (NAME) is not set, try \"xbuild-create <project|module> <name> [--force] \""
        return
    fi

    if [ $1. == project. ]; then
        # Create project folder if it doesn't exist
        if [ -d $2 ]; then
            if [ $3. == --force. ]; then
                echo "INFO: target folder ($2) already exist"
            else
                echo "ERROR: target folder ($2) already exist"
                return
            fi
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
            if [ $3. == --force. ]; then
                echo "WARNING: existing target file ($2/.gitignore) has been overwritten"
            else
                echo "INFO: target file ($2/.gitignore) already exist"
            fi
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
