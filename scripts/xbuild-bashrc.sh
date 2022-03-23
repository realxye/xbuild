# This bash script should be called from user's .bashrc file
# Add following line into ~/.bashrc file:
#     source <PATH-TO-THIS-FILE>

# Get and export XBUILDROOT
XBGetRoot()
{
    scriptDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
    rootDir=`echo $scriptDir | sed 's/\/[a-zA-Z]*$//'`
    echo $rootDir
}
export XBUILDROOT=`echo \`XBGetRoot\``
echo "XBuild Root: $XBUILDROOT"

# Start ssh agent if user's script exist
[ -f "$XBUILDROOT/scripts/userdata/xbuild-user-ssh-agent.sh" ] && source "$XBUILDROOT/scripts/userdata/xbuild-user-ssh-agent.sh"

# Set alias defined by user if user's script exist
[ -f "$XBUILDROOT/scripts/userdata/xbuild-user-alias.sh" ] && source "$XBUILDROOT/scripts/userdata/xbuild-user-alias.sh"
