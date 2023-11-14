
# Ensure environment has been set
if (NOT XBD_ENV_MACOS)
    message(FATAL_ERROR "Unsupported build environment. iOS target can only be built on Mac")
endif()

message(STATUS "Target Platform: iOS")

# set options
set(XBD_PLATFORM_NAME "iOS")
set(XBD_PLATFORM_IOS ON)
set(XBD_PLATFORM_MOBILE ON)

add_compile_definitions(XBD_PLATFORM_IOS)
add_compile_definitions(XBD_PLATFORM_NAME="${XBD_PLATFORM_NAME}")
add_compile_definitions(XBD_PLATFORM_MOBILE)

# Set common apple settings
include (xbuild-platform-apple)
