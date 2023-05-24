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

Before use xbuild, execute following command in Git Bash:

```bash
source <xbuild-root-dir>/xbuild.bashrc
```

This script will initialize xbuild and set proper environment values.

### Update XBUILD Profile

When system environment is changed, execute above command can also update xbuild profile.

## Create Target Project

### Module

Every single module must follow a specific folder structure:

```
    MODULE ROOT
    |---- Makefile
    |---- src/
    |---- [include]/
```

To create a single target project, use following command:

```bash
xbuild create-module <MODULE-NAME> <MODULE-TYPE>
```

### Project

A project includes one or more modules.

```
    PROJECT ROOT
    |---- ProjectSettings.txt
    |---- Module1
            |---- ...
    |---- Module2
            |---- ...
    |---- Module3
            |---- ...
    |---- Tests
            |---- Test1
                    |---- Makefile
                    |---- src/
                    |---- [include]/
            |---- Test2
                    |---- Makefile
                    |---- src/
                    |---- [include]/
```

To create a project, use following command:

```bash
xbuild create-project <PROJECT-NAME>
```

Then you can add modules using xbuild command.

### Build

To build target project, run following command:

```
xbuild build [--debug|--release] [--x86|--x64] [--target NAME] [--rebuild]
```

| Options | Description |
|---|---|
| --debug | Build configuration is `debug`, it cannot be used with other configuration options |
| --release | Build configuration is `release`, it cannot be used with other configuration options |
| --x86 | Build architecture is `x86`, it cannot be used with other architecture options |
| --x64 | Build architecture is `x64`, it cannot be used with other architecture options |
| --target NAME | Valid only in multiple targets project, only build specified target instead of all targets |
| --rebuild | Rebuild target(s) |
|   |   |

### Clean

To clean project, run following command:

```
xbuild clean [--debug|--release] [--x86|--x64] [--target NAME]
```

| Options | Description |
|---|---|
| --debug | Build configuration is `debug`, it cannot be used with other configuration options |
| --release | Build configuration is `release`, it cannot be used with other configuration options |
| --x86 | Build architecture is `x86`, it cannot be used with other architecture options |
| --x64 | Build architecture is `x64`, it cannot be used with other architecture options |
| --target NAME | Valid only in multiple targets project, only clean specified target instead of all targets. If it is not set, clean all targets |
|   |   |

## Commands Reference
