include_guard(GLOBAL)

# Ensure environment has been set
if (NOT XBD_ENV_WINDOWS)
    message(FATAL_ERROR "Unsupported build environment. Windows target can only be built on Windows")
endif()

message(STATUS "Target Platform: Windows")

# set variables
#   - XBuild Variables
set(XBD_PLATFORM_NAME "Windows" CACHE INTERNAL "Target platform name")
set(XBD_PLATFORM_WINDOWS ON CACHE BOOL "Target platform is Windows" FORCE)
set(XBD_PLATFORM_DESKTOP ON CACHE BOOL "Target platform is Desktop" FORCE)

#   - Default Windows Attributes
set(WINDOWS_VERSION_7 "0x0601" CACHE INTERNAL "WINVER for Windows 7")
set(WINDOWS_VERSION_8 "0x0602" CACHE INTERNAL "WINVER for Windows 8")
set(WINDOWS_VERSION_8_1 "0x0603" CACHE INTERNAL "WINVER for Windows 8.1")
set(WINDOWS_VERSION_10 "0x0A00" CACHE INTERNAL "WINVER for Windows 10")
set(WINDOWS_VERSION_DEFAULT "${WINDOWS_VERSION_10}" CACHE INTERNAL "Default WINVER (Windows 10)")
