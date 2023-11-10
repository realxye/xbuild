
# Ensure environment has been set
if (NOT XBD_ENV_MACOS)
    message(FATAL_ERROR "Unsupported build environment. Mac target can only be built on Mac")
endif()

message(STATUS "Target Platform: MacOS")

# set options
set(XBD_PLATFORM_NAME "MacOS")
set(XBD_PLATFORM_DESKTOP ON)

add_compile_definitions(XBD_PLATFORM_MACOS)
add_compile_definitions(XBD_PLATFORM_NAME="${XBD_PLATFORM_NAME}")
add_compile_definitions(XBD_PLATFORM_DESKTOP)

# Set common apple settings
include (xbuild-platform-apple)
