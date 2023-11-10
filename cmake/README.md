# XBUILD CMAKE

## Table of Content

- [Overview](#overview)
- [Prelude](#prelude)
- [Environment](#overview)
- [Platform](#platform)
- [Compiler](#compiler)
- [Utilities](#utilities)
  - [Options](#options)
  - [Log](#log)
  - [Find](#find)
  - [Core](#core)
  - [CMake](#cmake)

## Overview

| File | Description |
|----------|-----------------|
| **xbuild-prelude.cmake** | The master cmake file |
| **xbuild-env.cmake** | The top level environment file |
| **xbuild-env-windows.cmake** | The environment file for Windows |
| **xbuild-env-linux.cmake** | The environment file for Linux |
| **xbuild-env-macos.cmake** | The environment file for MacOS |
| **xbuild-platform.cmake** | The top level target platform file |
| **xbuild-platform-windows.cmake** | The target platform file for Windows |
| **xbuild-platform-linux.cmake** | The target platform file for Linux |
| **xbuild-platform-macos.cmake** | The target platform file for MacOS |
| **xbuild-platform-ios.cmake** | The target platform file for iOS |
| **xbuild-platform-android.cmake** | The target platform file for Android |
| **xbuild-compiler.cmake** | The top level compiler file |
| **xbuild-compiler-msvc.cmake** | The compiler file for MSVC |
| **xbuild-compiler-llvm.cmake** | The compiler file for LLVM |
| **xbuild-util-options.cmake** | Macros and functions to define options |
| **xbuild-util-log.cmake** | Macros and functions for logging |
| **xbuild-util-find.cmake** | Macros and functions to find packages |
| **xbuild-util-core.cmake** | XBuild core macros and functions |
| **xbuild-util-cmake.cmake** | Macros and functions for cmake |
| | |

## Prelude

The `xbuild-prelude.cmake` is the master cmake file.

## Environment

`xbuild-cmake` supports 3 major developing environments:

- Windows
- Linux
- MacOS

The top level environment file (xbuild-env.cmake) contains common environment settings and include proper child environment file (xbuild-env-windows.cmake, xbuild-env.linux.cmake or xbuild-env-macos.cmake) according to current OS.

## Platform

`xbuild-cmake` supports 5 major target platforms and 4 architectures.

- *Platforms*
  - Windows
  - Linux
  - MacOS
  - iOS
  - Android
- *Architectures*
  - x86
  - x64
  - arm
  - arm64

The top level platform file (xbuild-platform.cmake) contains common platform and architecture settings and include proper child platform file according to input target platform and architecture macros.

## Compiler

`xbuild-cmake` supports 2 major compilers `MSVC` and `LLVM`.

- *MSVC*
  - 2019
  - 2022
- *LLVM*
  - Official LLVM
  - MS LLVM
  - Apple LLVM

The top level compiler file (xbuild-compiler.cmake) contains common compiler settings and include proper child compiler file according to input macros.

## Utilities

`xbuild-cmake` defines its own helper functions.

### Options

The `xbuild-util-options.cmake` defines macros and functions to support Roblox options.

### Log

The `xbuild-util-log.cmake` defines macros and functions for loggings.

### Find

The `xbuild-util-find.cmake` defines useful macros and functions to find packages.

### Core

The `xbuild-util-core.cmake` defines useful core functions.

### CMake

The `xbuild-util-cmake.cmake` defines useful cmake helper functions.
