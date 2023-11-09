#[[
XBuild support 5 target platforms:
    - Windows (x86, x64, arm64)
    - Linux (x86, x64, arm64)
    - Mac OS (x64, arm64)
    - iOS (arm, arm64)
    - Android (arm, arm64)
]]

# Ensure target platform has been set
if (XBD_OPT_BUILD_PLATFORM STREQUAL "unknown")
    message(FATAL_ERROR "Target platform is not defined")
elseif (XBD_OPT_BUILD_PLATFORM STREQUAL "windows")
    include(xbuild-platform-windows)
elseif (XBD_OPT_BUILD_PLATFORM STREQUAL "macos")
    include(xbuild-platform-macos)
elseif (XBD_OPT_BUILD_PLATFORM STREQUAL "ios")
    include(xbuild-platform-ios)
elseif (XBD_OPT_BUILD_PLATFORM STREQUAL "linux")
    include(xbuild-platform-linux)
elseif (XBD_OPT_BUILD_PLATFORM STREQUAL "android")
    include(xbuild-platform-android)
else
    message(FATAL_ERROR "Unknown target platform (${XBD_OPT_BUILD_PLATFORM})")
endif()
