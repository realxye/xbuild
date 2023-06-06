# X's Build System #

This is a simple Make build system for Windows.

## Prerequisites

### Operating System

`xbuild` only support following operating systems:

- Windows 10 (64 bits) and above. (_Currently xbuild only support 64 bits Windows._)

### Visual Studio

This build system requires Visual Studio 2019 or above

### Python

This build system requires Python 3.10 or above

### Git

Latest version of Git is required. GitBash should be installed to execute build command and scripts.

### Windows Terminal (optional)

Windows Terminal is optional, but it is a good console, recommended.

## Installation and Initialization

### Clone

Use following command to get xbuild:

```bash
git clone --recurse-submodules git@github.com:realxye/xbuild.git
```

### Initialization

Before use xbuild, execute following command in Git Bash to initialize xbuild and generate proper profiles.

```bash
cd <xbuild-root-dir>
python xbuild.py
```

After xbuild get initialized, restart bash or run command to launch `xbuild` to current bash environment:

```bash
source xbuild.bashrc
```

### Update XBUILD Profiles

When system environment is changed, execute following command to update xbuild profile.

```bash
cdx
source xbuild.bashrc
```

## Create Project

### Project

A project includes project `Makefile` and one or more `modules`.

```
    PROJECT ROOT
    |---- Makefile
    |---- Module1
            |---- ...
    |---- Module2
            |---- ...
    |---- Module3
            |---- ...
    |---- Tests
            |---- TestModule1
            |---- TestModule2
```

To create a project, use following command:

```bash
xbuild-create project <PROJECT-NAME> [--force]
```

The `--force` option will force to create project even the folder or file with the same name already exist.

_Check [`xbuild/samples`](samples/README.md) for more information_

### Module

Every single module must follow a specific folder structure:

```
    MODULE ROOT
    |---- Makefile
    |---- src/
    |---- [include]/
```

To create a module for existing project, execute following command at project root directory:

```bash
xbuild-create module <MODULE-NAME>
```

_Check [`xbuild/samples`](samples/README.md) for more information_

### Build

To build target project, run following command in project's root directory:

```
xmake config=<release|debug> arch=<x86|x64|arm|arm64> [target=PATH-TO-SUB-MODULE]
```

| Options | Description |
|---|---|
| **config** | Build configuration should be `debug` or `release` |
| **arch** | Build architecture should be `x86`, `x64`, `arm` or `arm64` |
| **target** | The sub-module target path, if `target` present, only specified sub-module will be built |
|   |   |

### Clean

To clean project, run following command:

```
xbuild clean config=<release|debug> arch=<x86|x64|arm|arm64> [target=PATH-TO-SUB-MODULE]
```

| Options | Description |
|---|---|
| **config** | Build configuration should be `debug` or `release` |
| **arch** | Build architecture should be `x86`, `x64`, `arm` or `arm64` |
| **target** | The sub-module target path, if `target` present, only specified sub-module will be cleaned |
|   |   |

## Commands Reference

TBD