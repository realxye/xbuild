#[[
XBuild support 5 target platforms:
    - Windows (x86, x64, arm64)
    - Linux (x86, x64, arm64)
    - Mac OS (x64, arm64)
    - iOS (arm, arm64)
    - Android (arm, arm64)
]]

# Ensure environment has been set
if (NOT RBX_ENV_WINDOWS AND NOT RBX_ENV_MACOS AND NOT RBX_ENV_LINUX)
    message(FATAL_ERROR "Unsupported build environment. rbx-cmake only supports Windows, MacOS and Linux build environment.")
endif()