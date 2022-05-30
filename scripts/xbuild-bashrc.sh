# This bash script should be called from user's .bashrc file
# Add following line into ~/.bashrc file:
#     source <PATH-TO-THIS-FILE>

# Get and export XBUILDROOT
XBuildGetRoot()
{
    scriptDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
    rootDir=`echo $scriptDir | sed 's/\/[a-zA-Z]*$//'`
    echo $rootDir
}
export XBUILDROOT=`echo \`XBuildGetRoot\``

# Launch XBuild Core Scripts
source "$XBUILDROOT/scripts/xbuild-core.sh"

# Fix Mac Bash Color
if [ "$XBUILDHOSTOS" == "MacOS" ]; then
    parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "
    export CLICOLOR=1
    export LSCOLORS=ExFxBxDxCxegedabagacad
    alias ls='ls -GFh'
fi

# Create default "xbuild-user-ssh-agent.sh" if it doesn't exist
[ -f "$XBUILDROOT/scripts/userdata/xbuild-user-ssh-agent.sh" ] || tail -n +7 "$XBUILDROOT/scripts/userdata/template-xbuild-user-ssh-agent" > "$XBUILDROOT/scripts/userdata/xbuild-user-ssh-agent.sh"
# Start ssh agent
[ -f "$XBUILDROOT/scripts/userdata/xbuild-user-ssh-agent.sh" ] && source "$XBUILDROOT/scripts/userdata/xbuild-user-ssh-agent.sh"

# Create default "xbuild-user-alias.sh" if it doesn't exist
[ -f "$XBUILDROOT/scripts/userdata/xbuild-user-alias.sh" ] || tail -n +7 "$XBUILDROOT/scripts/userdata/template-xbuild-user-alias" > "$XBUILDROOT/scripts/userdata/xbuild-user-alias.sh"
# Set alias defined by user if user's script exist
[ -f "$XBUILDROOT/scripts/userdata/xbuild-user-alias.sh" ] && source "$XBUILDROOT/scripts/userdata/xbuild-user-alias.sh"

# Create default "xbuild-user-cmake-utils.sh" if it doesn't exist
[ -f "$XBUILDROOT/scripts/userdata/xbuild-user-cmake-utils.sh" ] || tail -n +7 "$XBUILDROOT/scripts/userdata/template-xbuild-user-cmake-utils" > "$XBUILDROOT/scripts/userdata/xbuild-user-cmake-utils.sh"
# Provide xbuild-cmake functions and alias
[ -f "$XBUILDROOT/scripts/userdata/xbuild-user-cmake-utils.sh" ] && source "$XBUILDROOT/scripts/userdata/xbuild-user-cmake-utils.sh"
