include_guard(GLOBAL)

# Ensure environment has been set
if (NOT XBD_ENV_MACOS)
    message(FATAL_ERROR "Unsupported build environment. Mac target can only be built on Mac")
endif()

message(STATUS "Target Platform: MacOS")

# set options
set(XBD_PLATFORM_NAME "MacOS" CACHE INTERNAL "Target platform name")
set(XBD_PLATFORM_MACOS ON CACHE BOOL "Target platform is MacOS" FORCE)
set(XBD_PLATFORM_DESKTOP ON CACHE BOOL "Target platform is Desktop" FORCE)

add_compile_definitions(XBD_PLATFORM_MACOS)
add_compile_definitions(XBD_PLATFORM_NAME="${XBD_PLATFORM_NAME}")
add_compile_definitions(XBD_PLATFORM_DESKTOP)

# Set common apple settings
include (xbuild-platform-apple)
