# XBUILD CMAKE

## Table of Content

## Compilers

XBuild support following compilers:

- Microsoft Visual C++ (Windows Only)
- Microsoft Clang (Windows Only)
- AppleClang (Apple Only)
- Clang (Any clang)

## Target Platforms

XBuild support following platform:

- Windows
  - Win32 Desktop
  - UWP (WIndows Store)
- Linux
- Android
- Apple
  - MacOS
  - iOS

## Target Type

- Win32 GUI Application (Windows Only)
- Windows Driver (Windows Only)
- Console Application
- Dynamic Linked Library
- Static Library

## Target Configuration

XBuild has 3 target build configurations:

- Debug
- Optimized
- Release

### Debug

The debug build has no optimization and with full debug information.

### Optimized

The optimized build has all the optimization, but without perform any release job.

### Release

The release build has all the optimizations and should perform all release jobs, for example:

- LTCG (Link Time Code Generation)
- Strip Debug Information
- Customized release steps

## Target Architeture

- x86
- x64
- arm64
