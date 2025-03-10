# Git Command:
#   git xbuild help
#   git xbuild create
#   git xbuild config
#   git xbuild build

xbuildhelp()
{
    if [ "$1" == "" ]; then
        echo "[xbuild help]"
        echo "  git-xbuild supports following commands:"
        echo "    - create"
        echo "    - config"
        echo "    - build"
        echo "  Use \"git xbuild help <COMMAND>\" to show detail command help."
    elif [ "$1" == "create" ]; then
        echo "[xbuild help]"
        echo "  \"create\" command is used to create xbuild target."
        echo "  Command Format:"
        echo "    git xbuild create <-t|--target TARGETNAME> <--target-type TYPE> [--kernel]"
        echo "      -t, --target: the target name"
        echo "      --kernel: the target is in kernel mode"
        echo "      --target-type: the target type, supports following values"
        echo "        * console: target is a consle app"
        echo "        * app: target is a GUI app"
        echo "        * slib: target is a static-linked library,"
        echo "          user mode or kernel mode (if --kernel is used, Windows Only)"
        echo "        * dlib: target is a dynamic-linked library, user mode"
        echo "          user mode or kernel mode (if --kernel is used, Windows Only)"
        echo "        * test: target is a user mode test app"
    elif [ "$1" == "config" ]; then
        echo "[xbuild help]"
        echo "  \"config\" command is used to config current xbuild project."
        echo "  Command Format:"
        echo "    git xbuild config <-g|--generator make|vs2019|vs2022|xcode> <-a|--architecture x86|x64|arm|arm64>"
        echo "                      <-c|--configuration debug|release> [--compiler msvc|llvm] [-D*=ON|OFF]"
        echo "      -g, --generator: decide how to generator the config. xbuild supports following 4 values:"
        echo "        * make: generate a Unix Make style project"
        echo "        * vs2019: generate a Visual Studio 2019 project (Windows Only)"
        echo "        * vs2022: generate a Visual Studio 2022 project (Windows Only)"
        echo "        * xcode: generate a Xcode project (Mac Only)"
        echo "      -a, --architecture: defines the architecture to config. xbuild supports following 4 values: x86, x64, arm and arm64."
        echo "      -c, --configuration: defines the configuration used by config. It is one of following two values: debug and release."
        echo "      --compiler: (optional) decides which compiler should be used. It supports following 2 values: llvm and msvc (Windows Only)."
        echo "                  If not defined, default to llvm."
        echo "      -D*=ON|OFF: xbuild use prefix -D to define its options status (override default status). For example,"
        echo "                  -DXBDOPT_DEBUG_VERBOSE=ON will turn option XBDOPT_DEBUG_VERBOSE on."
    elif [ "$1" == "build" ]; then
        echo "[xbuild help]"
        echo "  \"build\" command is used to build a target in current xbuild project."
        echo "  Command Format:"
        echo "    git xbuild build <-a|--architecture x86|x64|arm|arm64> <-c|--configuration debug|release> <-t|--target TARGETNAME>"
        echo "      -a, --architecture: defines the architecture to config. xbuild supports following 4 values: x86, x64, arm and arm64."
        echo "      -c, --configuration: defines the configuration used by config. It is one of following two values: debug and release."
        echo "      -t, --target: the target name."
    else
        echo "[xbuild help]"
        echo "  Unknown Command: \"$1\""
    fi
}

# No parameters, print usage
if [[ -z $1 ]]; then 
    (xbuildhelp)
    exit 1
fi

# Read XBuild Command
XBUILD_COMMAND=$1
shift # move to next argument
if [ "$XBUILD_COMMAND" == "help" ]; then
    (xbuildhelp $1)
    exit 0
elif [ "$XBUILD_COMMAND" == "create" ]; then
    echo "Command: $XBUILD_COMMAND"
elif [ "$XBUILD_COMMAND" == "config" ]; then
    echo "Command: $XBUILD_COMMAND"
elif [ "$XBUILD_COMMAND" == "build" ]; then
    echo "Command: $XBUILD_COMMAND"
else
    echo "Unknown Command: $XBUILD_COMMAND"
    exit 1
fi

echo "Host OS: $XBUILD_HOST_OSNAME"

# [Valid XBuild Parameters]
# xbuild target name
XBUILD_TARGET=
# xbuild target type, includes following values: console, app, slib, dlib, test
XBUILD_TARGETTYPE=
# xbuild options: input option values to override default values
XBUILD_OPTIONS=()
# xbuild architecture, valid options are: x86, x64, arm, arm64
XBUILD_ARCH=
# xbuild compiler, valid options are: msbuild, llvm
XBUILD_COMPILER=
# xbuild project generator, valid options are: make, vs2019, vs2022, xcode
XBUILD_GENERATOR=
# xbuild toolchain, valid options are: vs2019, vs2022, llvm
XBUILD_TOOLCHAIN=
# xbuild configuration, valid options are: debug, release
XBUILD_CONFIGURATION=
# xbuild mode: user, kernel
XBUILD_MODE=user

# positional arguments
POSITIONAL_ARGS=()

# Read all arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--target)
      XBUILD_TARGET=$2
      shift # past argument
      shift # past value
      ;;
    -c|--configuration)
      [[ "$XBUILD_CONFIGURATION" == "" ]] || echo "Error: configuration $XBUILD_CONFIGURATION and $2 cannot be set at the same time"
      [[ "$2" == "" ]] && echo "Error: missing configuration value"
      [[ "$2" == "debug" || "$2" == "release" ]] || echo "Warning: ignore unknown compiler $2"
      [[ "$2" == "debug" || "$2" == "release" ]] && XBUILD_COMPILER=$2
      shift # past argument
      shift # past value
      ;;
    -a|--architecture)
      [[ "$XBUILD_ARCH" == "" ]] || echo "Error: compiler $XBUILD_ARCH and $2 cannot be set at the same time"
      [[ "$2" == "" ]] && echo "Error: missing architecture value"
      [[ "$2" == "x86" || "$2" == "x64" || "$2" == "arm" || "$2" == "arm64" ]] || echo "Warning: ignore unknown compiler $2"
      [[ "$2" == "x86" || "$2" == "x64" || "$2" == "arm" || "$2" == "arm64" ]] && XBUILD_ARCH=$2
      shift # past argument
      shift # past value
      ;;
    -g|--generator)
      [[ "$XBUILD_GENERATOR" == "" ]] || echo "Error: generator $XBUILD_GENERATOR and $2 cannot be set at the same time"
      [[ "$2" == "" ]] && echo "Error: missing project type"
      [[ "$2" == "make" || "$2" == "vs2019" || "$2" == "vs2022" || "$2" == "xcode" ]] || echo "Warning: ignore unknown generator $2"
      [[ "$2" == "make" || "$2" == "vs2019" || "$2" == "vs2022" || "$2" == "xcode" ]] && XBUILD_PROJECTFILE=$2
      shift # past argument
      shift # past value
      ;;
    -t|--toolchain)
      [[ "$XBUILD_TOOLCHAIN" == "" ]] || echo "Error: toolchain $XBUILD_TOOLCHAIN and $2 cannot be set at the same time"
      [[ "$2" == "" ]] && echo "Error: missing toolchain value"
      [[ "$2" == "vs2019" || "$2" == "vs2022" || "$2" == "xcode" ]] || echo "Warning: ignore unknown toolchain $2"
      [[ "$2" == "vs2019" || "$2" == "vs2022" || "$2" == "xcode" ]] && XBUILD_TOOLCHAIN=$2
      shift # past argument
      shift # past value
      ;;
    --compiler)
      [[ "$XBUILD_COMPILER" == "" ]] || echo "Error: compiler $XBUILD_COMPILER and $2 cannot be set at the same time"
      [[ "$2" == "" ]] && echo "Error: missing compiler value"
      [[ "$2" == "msvc" || "$2" == "llvm" ]] || echo "Warning: ignore unknown compiler $2"
      [[ "$2" == "msvc" || "$2" == "llvm" ]] && XBUILD_COMPILER=$2
      shift # past argument
      shift # past value
      ;;
    --kernel)
      XBUILD_MODE=kernel
      shift # past argument
      ;;
    --target-type)
      [[ "$XBUILD_TARGETTYPE" == "" ]] || echo "Error: compiler $XBUILD_TARGETTYPE and $2 cannot be set at the same time"
      [[ "$2" == "" ]] && echo "Error: missing target type value"
      [[ "$2" == "console" || "$2" == "app" || "$2" == "slib" || "$2" == "dlib" || "$2" == "test" ]] || echo "Warning: ignore unknown target type $2"
      [[ "$2" == "console" || "$2" == "app" || "$2" == "slib" || "$2" == "dlib" || "$2" == "test" ]] && XBUILD_TARGETTYPE=$2
      shift # past argument
      shift # past value
      ;;
    -D*)
      [[ "$XBUILD_OPTIONS" == "" ]] && XBUILD_OPTIONS+=" " # add space
      XBUILD_OPTIONS+="${1:2}" # save xbuild options
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

# Check command arguments
if [ "$XBUILD_HOST_OSNAME" == "Windows" ]; then
    # Check generator
    if [ "$XBUILD_GENERATOR" == "" ]; then
        XBUILD_GENERATOR=make
        echo "[Warning] Generator is not specified, default to $XBUILD_GENERATOR"
    else
        if [[ "$XBUILD_GENERATOR" == "make" || "$XBUILD_GENERATOR" == "vs2019" || "$XBUILD_GENERATOR" == "vs2022" ]]; then
            echo "[OK] Generator = $XBUILD_GENERATOR"
        else
            echo "[Error] generator $XBUILD_GENERATOR is not supported on Mac"
            exit 1
        fi
    fi
    echo "[Arguments Check] Passed"
elif [ "$XBUILD_HOST_OSNAME" == "Darwin" ]; then
    # Check generator
    if [ "$XBUILD_GENERATOR" == "" ]; then
        XBUILD_GENERATOR=make
        echo "[Warning] Generator is not specified, default to $XBUILD_GENERATOR"
    else
        if [[ "$XBUILD_GENERATOR" == "make" || "$XBUILD_GENERATOR" == "xcode" ]]; then
            echo "[OK] Generator = $XBUILD_GENERATOR"
        else
            echo "[Error] generator $XBUILD_GENERATOR is not supported on Mac"
            exit 1
        fi
    fi
    echo "[Arguments Check] Passed"
else
    # Check generator
    if [ "$XBUILD_GENERATOR" == "" ]; then
        XBUILD_GENERATOR=make
        echo "[Warning] Generator is not specified, default to $XBUILD_GENERATOR"
    else
        if [[ "$XBUILD_GENERATOR" == "make" ]]; then
            echo "[OK] Generator = $XBUILD_GENERATOR"
        else
            echo "[Error] generator $XBUILD_GENERATOR is not supported on this platform"
            exit 1
        fi
    fi
    echo "[Arguments Check] Passed"
fi

# If command is config or build, we want to re-config the cmake
if [[ "$XBUILD_COMMAND" == "config" || "$XBUILD_COMMAND" == "build" ]]; then
    echo "Configure cmake project"
fi

# If command is build, we want to build target
if [ "$XBUILD_COMMAND" == "build" ]; then
    echo "Build target: $XBUILD_TARGET"
fi

exit 0
