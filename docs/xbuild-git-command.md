# XBUILD GIT COMMAND

## Overview

`xbuild` system integrate its command with Git which can be called in following format:

```
git xbuild <command> ...
```

## Command

<!--

### **Command: update** (TODO)

The `update` command update `xbuild` various information, includes:

- `git xbuild update compiler`: update compiler information
- `git xbuild update sdk`: update sdk information

-->

### **Command: help**

The `help` command is used to show `xbuild` help information:

```
git xbuild help [COMMAND]
```

### **Command: create**

The `create` command is used to create targets from the predefined templates. The command is in following format:

```
git xbuild create <-t|--target TARGETNAME> <--target-type TYPE> [--kernel]
```

- -t, --target: the target name
- --kernel: the target is in kernel mode
- --target-type: the target type, supports following values
    - console: target is a console app
    - app: target is a GUI app
    - slib: target is a static-linked library, user mode or kernel mode (if `--kernel` is used, Windows Only)
    - dlib: target is a dynamic-linked library, user mode or kernel mode driver (if `--kernel` is used, Windows Only)
    - test: target is a user mode test app

### **Command: config**

The `config` command is used to configure current project. The full command line is like below:

```
git xbuild config <-g|--generator make|vs2019|vs2022|xcode> <-a|--architecture x86|x64|arm|arm64> <-c|--configuration debug|release> [--compiler msvc|llvm] [-D*=ON|OFF]
```

#### Parameters

- -g, --generator: decide how to generator the config. `xbuild` supports following 4 values: `make`, `vs2019`, `vs2022` and `xcode`.
    -  **make**: generate a Unix Make style project
    -  **vs2019**: generate a Visual Studio 2019 project (Windows Only)
    -  **vs2022**: generate a Visual Studio 2022 project (Windows Only)
    -  **xcode**: generate a Xcode project (Mac Only)
- -a, --architecture: defines the architecture to config. `xbuild` supports following 4 values: `x86`, `x64`, `arm` and `arm64`.
- -c, --configuration: defines the configuration used by config. It is one of following two values: `debug` and `release`.
- --compiler: (optional) decides which compiler should be used. It supports following 2 values: `llvm` and `msvc` (Windows Only). If not defined, default to `llvm`.
- -D*=ON|OFF: `xbuild` use prefix `-D` to define its options status (override default status). For example, `-DXBDOPT_DEBUG_VERBOSE=ON` will turn option `XBDOPT_DEBUG_VERBOSE` on.

### **Command: build**

The `build` command is used to build specific target in current configured project. The full command line is like below:

```
git xbuild build <-a|--architecture x86|x64|arm|arm64> <-c|--configuration debug|release> <-t|--target TARGETNAME>
```

